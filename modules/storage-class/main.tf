# StorageClass para volumes persistentes no Cinder (driver cinder.csi.openstack.org,
# já instalado pelo Magnum com cinder_csi_enabled = true).
resource "kubernetes_storage_class_v1" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.name
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = var.is_default ? "true" : "false"
    }
  }

  storage_provisioner    = "cinder.csi.openstack.org"
  reclaim_policy         = var.reclaim_policy
  volume_binding_mode    = "WaitForFirstConsumer" # cria o volume na mesma zona do pod
  allow_volume_expansion = true

  parameters = {
    type = var.volume_type
  }
}
