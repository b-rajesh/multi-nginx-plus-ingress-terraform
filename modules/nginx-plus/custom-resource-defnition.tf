 # Apply kubectl to create custom resource defnition for transportservers , virtualservers & virtualserverroutes. 
 # This will be replaced one Terraform has https://github.com/hashicorp/terraform-provider-kubernetes-alpha as GA
 # The yaml files inside crd folder should be kept up to date, retrieve it from here https://github.com/nginxinc/kubernetes-ingress/tree/master/deployments/common
resource "null_resource" "cluster" {
  depends_on = [kubernetes_config_map.nginx-ingress-config-map, kubernetes_config_map.micro_proxy_server_config_map, kubernetes_namespace.nginx-plus-ingress-ns]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/crd/"
  }
}

resource "null_resource" "create_virtual_route_in_edge_proxy" {
  depends_on = [null_resource.cluster, kubernetes_namespace.nginx-plus-ingress-ns]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/edgeproxy_virtualroute_crd/ --validate=false"
  }
}

resource "null_resource" "create_app_protect_policies_in_edge_proxy" {
  depends_on = [null_resource.cluster, kubernetes_namespace.nginx-plus-ingress-ns, kubernetes_namespace.microservice-namespace]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/app_protect_policies/ --validate=false"
  }
}