/*
resource "null_resource" "build-kic" {
depends_on = 
  provisioner "local-exec" {
    command = "docker rmi ${var.ingress_controller_prefix}/${var.ingress_controller_image_name}:${var.ingress_conroller_version}"
  }
  provisioner "local-exec" {
    command = "docker rmi ${var.ingress_controller_prefix}/app-protect-${var.ingress_controller_image_name}:${var.ingress_conroller_version}"
  }
} */
module "prometheus" {
  source = "./modules/prometheus-grafana"

  load_config_file       = true
  host                   = ""
  token                  = ""
  cluster_ca_certificate = ""
  client_key             = ""
  client_certificate     = ""
  depends_on_nginx_plus  = ["true"]
}

module "api-deployment" {
  source = "./modules/apis"

  load_config_file       = true
  host                   = ""
  token                  = ""
  cluster_ca_certificate = ""
  client_key             = ""
  client_certificate     = ""
  weather-api-image      = var.weather-api-image
  echo-api-image         = var.echo-api-image
  depends_on_nginx_plus  = [module.nginx-plus-ingress-deployment.lb_ip]

}

locals {
  external_loadbalancer = module.nginx-plus-ingress-deployment.lb_ip
  grafana_dashboard_url = module.prometheus.lb_ip
}

module "nginx-plus-ingress-deployment" {
  source = "./modules/nginx-plus"

  tls_crt                   = "${file("default.crt")}"
  tls_key                   = "${file("default.key")}"
  name_of_ingress_container = var.name_of_ingress_container
  image                     = "ingress/${var.ingress_controller_image_name}:${var.ingress_conroller_version}"
  nginx_app_protect_image   = "ingress/${var.ingress_controller_app_protect_image_name}:${var.ingress_conroller_version}"
  name_of_app_protect_ingress_container = var.ingress_controller_app_protect_image_name  

  load_config_file          = true
  host                      = ""
  token                     = ""
  cluster_ca_certificate    = ""
  client_key                = ""
  client_certificate        = ""
  depends_on_kube           = ["true"]
}

module "kic" {
  source                        = "./modules/kic"
  ingress_conroller_version     = var.ingress_conroller_version
  ingress_controller_prefix     = "ingress"
  ingress_controller_image_name = var.ingress_controller_image_name
  name_of_app_protect_ingress_container = var.ingress_controller_app_protect_image_name
}

resource "random_pet" "myprefix" {
  length = 1
  prefix = var.prefix
}

