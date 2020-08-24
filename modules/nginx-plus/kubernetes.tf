/******************************************
  Configure provider
 *****************************************/
provider "kubernetes" {
  load_config_file       = var.load_config_file
  host                   = var.host
  token                  = var.token
  client_key             = var.client_key
  cluster_ca_certificate = var.cluster_ca_certificate
  client_certificate     = var.client_certificate
}
resource "kubernetes_namespace" "nginx-plus-ingress-ns" {
  metadata {
    annotations = {
      name = "nginx-plus-ingress-namespace"
    }

    labels = {
      namespace = "nginx-plus-ingress-ns"
    }

    name = "nginx-plus-ingress-ns"
  }
  depends_on = [var.depends_on_kube]
}

resource "kubernetes_namespace" "microservice-namespace" {
  depends_on = [var.depends_on_kube]
  metadata {
    annotations = {
      name = "microservice-namespace"
    }

    labels = {
      namespace = "microservice-namespace"
    }

    name = "microservice-namespace"
  }
}

resource "kubernetes_service_account" "nginx-plus-ingress-sa" {
  metadata {
    name      = "nginx-plus-ingress-service-account"
    namespace = kubernetes_namespace.nginx-plus-ingress-ns.metadata[0].name
  }
  automount_service_account_token = true
  //secret = kubernetes_secret.nginx-plus-ingress-default-secret.metadata.0.name
  image_pull_secret {
    name = "nginx-plus-ingress-default-secret" #revisit
  }
  depends_on = [var.depends_on_kube]
}

resource "kubernetes_secret" "nginx-plus-ingress-default-secret" {
  metadata {
    name      = "nginx-plus-ingress-default-secret"
    namespace = kubernetes_namespace.nginx-plus-ingress-ns.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.nginx-plus-ingress-sa.metadata.0.name
      "kubernetes.io/service-account.uid"  = kubernetes_service_account.nginx-plus-ingress-sa.metadata.0.uid
    }
  }
  data = {
    "tls.crt" = var.tls_crt,
    "tls.key" = var.tls_key
  }
  type       = "Opaque"
  depends_on = [var.depends_on_kube]
}



