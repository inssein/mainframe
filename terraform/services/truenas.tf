resource "kubernetes_manifest" "traefik_helmchartconfig" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"
    metadata = {
      name      = "traefik"
      namespace = "kube-system"
    }
    spec = {
      valuesContent = <<-EOT
providers:
  file:
    enabled: true
    content: >-
      api:
        insecure: true
      http:
        services:
          truenas:
            loadBalancer:
              servers:
              - url: "http://192.168.0.228/"
        routers:
          truenas-router:
            rule: "Host(`nas.mnara.ca`)"
            entryPoints:
              - "websecure"
            service: "truenas"
            tls: {}
      EOT
    }
  }
}