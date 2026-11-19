# Kubeconfig gerado pela camada de infra (pasta acima)
kubeconfig_path = "../kubeconfig/k8s-dev.yaml"

# ---------- StorageClass (volumes persistentes no Cinder) ----------
storage_class_enabled = true
# storage_volume_type = "f7b5f05d-130f-4546-8f4a-ea3ceda7df8d"   # SSD Standard (padrão)

# ---------- Traefik ----------
traefik_enabled       = true
traefik_chart_version = "42.4.1"

# ---------- Argo CD ----------
argocd_enabled       = true
argocd_chart_version = "10.18.0"

# Domínio do Argo CD (opcional). Sem domínio, o acesso é por port-forward.
# Com domínio, aponte o DNS para o IP do output traefik_ip.
# argocd_host = "argocd.cliente.com.br"

# ---------- Monitoramento (Prometheus + Grafana) ----------
prometheus_enabled       = true
prometheus_chart_version = "93.4.0"

grafana_enabled       = true
grafana_chart_version = "14.5.0"
# grafana_host = "grafana.cliente.com.br"   # opcional; aponte o DNS para o traefik_ip

# Disco persistente para métricas e dados do Grafana.
# Usa a StorageClass criada acima (storage_class_enabled = true).
monitoring_storage_enabled = false
# storage_class           = "outra-storageclass"     # opcional; null = csi-cinder-ssd
prometheus_storage_size = "20Gi"
grafana_storage_size    = "5Gi"
