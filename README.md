# Kubernetes no OpenStack do zero com Terraform

Parte de um projeto **vazio** no painel e entrega um cluster Kubernetes pronto, sem nenhum
passo manual além da credencial. Usa o Kubernetes gerenciado do Nuvion (OpenStack Magnum),
o mesmo da tela **Computar > Kubernetes > Criar cluster**.

> **Procedimento completo, passo a passo:** [docs/PROCEDIMENTO.md](docs/PROCEDIMENTO.md)

## O que é criado

São duas camadas, cada uma com o seu `terraform apply` e o seu state:

```
1) environments/<amb>/            (infra)
 ├── module.network
 │    ├── rede          <cluster>-net
 │    ├── subnet        <cluster>-subnet (com DNS)
 │    ├── roteador      <cluster>-router (saída para a internet)
 │    └── interface     subnet ↔ roteador
 └── module.k8s
      ├── template      <cluster>-template (versão do K8s, Cilium, boot em volume)
      ├── chave SSH     <cluster>-key
      ├── cluster       <cluster>  (mestres + workers + load balancer da API)
      └── kubeconfig    ./kubeconfig/<cluster>.yaml

2) environments/<amb>/platform/   (platform, usa o kubeconfig acima)
 ├── module.storage_class  StorageClass padrão csi-cinder-ssd (volumes persistentes no Cinder)
 ├── module.traefik     ingress controller com IP público (LoadBalancer), HTTP → HTTPS
 ├── module.argocd      acesso por port-forward ou por domínio via Traefik
 ├── module.prometheus  kube-prometheus-stack: Prometheus, Alertmanager, node-exporter, kube-state-metrics
 └── module.grafana     dashboards do cluster já carregados, Prometheus como fonte de dados
```

## Estrutura

```
sic-k8s-zero/
├── modules/
│   ├── network/         # COMO a rede é criada
│   ├── k8s-cluster/     # COMO o cluster é criado (template, labels, cluster)
│   ├── storage-class/   # StorageClass padrão do Cinder (volumes persistentes)
│   ├── traefik/         # um módulo por componente da platform
│   │   └── values.yaml       # values do chart, em YAML puro
│   ├── argocd/
│   │   ├── values.yaml
│   │   └── values-ingress.yaml.tftpl   # usado só quando argocd_host é preenchido
│   ├── prometheus/
│   │   ├── values.yaml
│   │   └── values-storage.yaml.tftpl   # usado só com monitoring_storage_enabled
│   └── grafana/
│       ├── values.yaml
│       ├── values-ingress.yaml.tftpl
│       └── values-storage.yaml.tftpl
└── environments/
    ├── dev/             # projeto 862-Default
    └── prod/            # projeto 862-Producao
        ├── main.tf           # igual em todos os ambientes
        ├── variables.tf      # igual em todos os ambientes
        ├── outputs.tf
        ├── terraform.tfvars  # ← o único arquivo que muda (infra)
        └── platform/
            ├── main.tf / variables.tf / outputs.tf
            └── terraform.tfvars  # ← kubeconfig, liga/desliga, versões, domínio
```

Por que duas camadas: o load balancer do Traefik é criado pelo Kubernetes e não fica no state
da infra. Separando, o `destroy` da platform remove o load balancer antes de a infra apagar a
rede, e nada fica órfão. Os providers Helm/Kubernetes também só são configurados depois que o
cluster existe.

| O quê | Onde fica | Vai para o Git? |
|---|---|---|
| **Credencial** | `~/.config/openstack/clouds.yaml` | ❌ Nunca |
| **Configuração** | `environments/<amb>/terraform.tfvars` | ✅ Sim |
| **Estado** | `terraform.tfstate` de cada ambiente | ❌ Não (contém o kubeconfig) |

## Passo manual (único): credencial

A credencial de API é **por projeto**. Para cada projeto do painel:

1. Troque o projeto no seletor do topo do painel (ex.: `862-Producao`).
2. **Credenciais de API** > criar. Copie o ID e o secret (o secret só aparece uma vez).
3. Adicione a entrada no `~/.config/openstack/clouds.yaml` (modelo em `clouds.yaml.example`).

```bash
chmod 600 ~/.config/openstack/clouds.yaml
export OS_CLOUD=saveincloud-prod
openstack token issue -c expires
```

## Antes do primeiro apply

```bash
openstack image list | grep -i coreos              # imagem -> image no tfvars
openstack network list --external                  # deve existir 1 rede externa
openstack limits show --absolute | grep -iE 'ram|cores|floating'
```

## Subir um ambiente

```bash
cd environments/prod          # ou environments/dev
terraform init
terraform plan -out=k8s.plan
terraform apply k8s.plan      # 15 a 25 minutos
```

```bash
export KUBECONFIG=$(terraform output -raw kubeconfig_path)
kubectl get nodes
```

Depois, Traefik e Argo CD:

```bash
cd platform
terraform init
terraform plan -out=platform.plan
terraform apply platform.plan     # 5 a 10 minutos
terraform output traefik_ip
terraform output -raw argocd_admin_password; echo
kubectl -n argocd port-forward svc/argocd-server 8080:443   # https://localhost:8080, usuário admin
```

Apagar tudo, **nesta ordem**:

```bash
cd environments/prod/platform && terraform destroy   # 1. Traefik e Argo CD (remove o load balancer)
cd ..                         && terraform destroy   # 2. cluster, template, chave e rede
```

## Componentes da platform

Cada componente é um módulo em `modules/<componente>`, com:

| Arquivo | Para quê |
|---|---|
| `values.yaml` | Configuração do chart Helm, em YAML puro (como num `helm upgrade -f`) |
| `variables.tf` | `enabled`, `chart_version` e o que o ambiente precisa passar |
| `outputs.tf` | O que o componente expõe (IP, senha, URL) |

| Quero... | Faço |
|---|---|
| Atualizar um componente | Mudo `<componente>_chart_version` no tfvars da platform |
| Desligar um componente | `<componente>_enabled = false` |
| Ajustar a configuração | Edito `modules/<componente>/values.yaml` |
| Acrescentar um componente (ex.: cert-manager) | Crio `modules/cert-manager/` e um bloco `module` em `environments/<amb>/platform/main.tf` |

### Monitoramento (Prometheus + Grafana)

- O módulo `prometheus` instala o **kube-prometheus-stack com o Grafana desligado**, mas publica os
  dashboards e a fonte de dados como ConfigMaps (`forceDeployDashboards`/`forceDeployDatasources`).
- O módulo `grafana` (chart do repositório `grafana-community`, para onde o chart oficial migrou)
  carrega esses ConfigMaps pelo *sidecar*: sobe com o Prometheus configurado e os dashboards prontos.
- Os dois ficam no namespace `monitoring`.
- etcd, scheduler, controller-manager e kube-proxy ficam desligados no `values.yaml` do Prometheus:
  no Magnum eles não expõem métricas fora dos mestres e gerariam alertas falsos.
- Disco persistente é opcional (`monitoring_storage_enabled`) e usa a StorageClass criada pelo
  módulo `storage-class`. O Magnum instala o driver do Cinder, mas **não cria StorageClass**.
- **Certificado da API sem AKI:** o certificado da API dos clusters Magnum não tem a extensão
  *Authority Key Identifier*. Ferramentas em Python 3.13+ (como o sidecar do Grafana) recusam esse
  certificado. O `values.yaml` do Grafana usa `DISABLE_X509_STRICT_VERIFICATION=true`, que mantém
  a validação contra a CA e só desliga a regra estrita. Outros componentes em Python 3.13+ podem
  precisar do mesmo ajuste.

Acesso:

```bash
terraform output -raw grafana_admin_password; echo           # usuário admin
kubectl -n monitoring port-forward svc/grafana 3000:80       # http://localhost:3000
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

## Por que `plan -out` + `apply k8s.plan`

O `apply` do arquivo executa **exatamente** o plano revisado. Se algo mudou depois do plan,
o Terraform recusa (`Saved plan is stale`) em vez de aplicar algo diferente.

## Bom saber

- **Workers em dois grupos:**
  - grupo padrão (`worker_count`): base fixa. Mudar o valor **recria o cluster**;
  - grupo `autoscale`: é por ele que se aumenta, diminui ou liga/desliga o autoscaling,
    **sem recriar** nada.
- **Liga/desliga do autoscaling** (`terraform.tfvars`):

  | `autoscaling_enabled` | Grupo `autoscale` |
  |---|---|
  | `true` | Varia entre `autoscaling_min` e `autoscaling_max` |
  | `false` | Fica fixo em `autoscaling_min` |

  Trocar o valor, ou mudar `autoscaling_min`/`autoscaling_max`, altera só os limites do
  grupo (alguns segundos). O autoscaler fica sempre instalado no cluster.
- Monitoramento (`monitoring_enabled`) fica nas labels do cluster: mudar recria o cluster.
- As labels do painel ficam em `modules/k8s-cluster/labels.tf`. Para outra versão do
  Kubernetes, compare com um cluster novo criado pelo painel.
- Se der `CREATE_FAILED`: `openstack coe cluster show <nome> -c status_reason`.
- **Falso `DELETE_COMPLETE`:** a API do Magnum (via proxy do painel) às vezes devolve esse status
  durante a criação, e o Terraform desiste com `unexpected state 'DELETE_COMPLETE'`, embora o
  recurso continue sendo criado. Não rode `destroy`: espere o `CREATE_COMPLETE`, rode
  `terraform untaint <endereço do erro>` e confira com `terraform plan` (deve dar `No changes`).
- O Nuvion tem duas redes externas (`public` e `cross_service`): o tfvars fixa `external_network_name = "public"`.
- Na API a região se chama `RegionOne` (o painel mostra SP1).
