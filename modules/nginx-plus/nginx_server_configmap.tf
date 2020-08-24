resource "kubernetes_config_map" "edge_proxy_server_config_map" {
  metadata {
    name      = "edge-proxy-server-config-map"
    namespace = kubernetes_namespace.nginx-plus-ingress-ns.metadata[0].name
  }
  data = {
    server-snippets        = "${file("${path.module}/nginx_server_snippet/edge_proxy_server_snippet.conf")}"
  }

}


resource "kubernetes_config_map" "nginx-ingress-config-map" {
  metadata {
    name      = "nginx-ingress-config-map"
    namespace = kubernetes_namespace.nginx-plus-ingress-ns.metadata[0].name
  }

  data = {
    worker-processes     = "24"
    worker-connections   = "100000"
    worker-rlimit-nofile = "102400"
    worker-cpu-affinity  = "auto 111111111111111111111111"
    keepalive            = "200"
    //main-template        = "${file("${path.module}/nginx_server_snippet/main_template_file.conf")}"
  }

}

resource "kubernetes_config_map" "micro_proxy_server_config_map" {
  metadata {
    name      = "micro-proxy-server-config-map"
    namespace = kubernetes_namespace.nginx-plus-ingress-ns.metadata[0].name
  }
  data = {
    server-snippets        = "${file("${path.module}/nginx_server_snippet/micro_proxy_server_snippet.conf")}"
  }

}

