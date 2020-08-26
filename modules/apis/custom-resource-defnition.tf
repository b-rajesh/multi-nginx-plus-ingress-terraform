 # Apply kubectl to create custom resource defnition for transportservers , virtualservers & virtualserverroutes. 
 # This will be replaced one Terraform has https://github.com/hashicorp/terraform-provider-kubernetes-alpha as GA
 # The yaml files inside crd folder should be kept up to date, retrieve it from here https://github.com/nginxinc/kubernetes-ingress/tree/master/deployments/common
resource "null_resource" "create_virtual_route_in_micro_proxy" {
  depends_on = [var.depends_on_nginx_plus, kubernetes_service.echo-service, kubernetes_service.weather-service]
  provisioner "local-exec" {
    command = "kubectl apply -f  ${path.module}/virtual_server_ingress_crd/ --validate=false"
  }
}