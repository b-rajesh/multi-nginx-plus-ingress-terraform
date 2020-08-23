resource "kubernetes_service_account" "nginx_kic_micro_proxy_sa" {
  metadata {
    name      = "nginx-kic-micro-proxy-sa"
    namespace = kubernetes_namespace.microservice-namespace.metadata[0].name
  }
  automount_service_account_token = true
  //secret = kubernetes_secret.nginx-plus-ingress-default-secret.metadata.0.name
  image_pull_secret {
    name = "nginx_kic_default_secret" #revisit
  }
}

resource "kubernetes_secret" "nginx_kic_default_secret" {
  metadata {
    name      = "nginx-kic-default-secret"
    namespace = kubernetes_namespace.microservice-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.nginx_kic_micro_proxy_sa.metadata.0.name
      "kubernetes.io/service-account.uid"  = kubernetes_service_account.nginx_kic_micro_proxy_sa.metadata.0.uid
    }
  }
  data = {
    "tls.crt" = var.tls_crt,
    "tls.key" = var.tls_key
  }
  type       = "Opaque"
}


resource "kubernetes_cluster_role_binding" "nginx_kic_micro_proxy_cluster_role_binding" {
  metadata {
    name = "nginx-kic-micro-proxy-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nginx-plus-ingress-cluster-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx_kic_micro_proxy_sa.metadata.0.name
    namespace = kubernetes_namespace.microservice-namespace.metadata[0].name
  }
  depends_on = [kubernetes_service_account.nginx_kic_micro_proxy_sa]
}