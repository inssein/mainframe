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
        insecure: true
      http:
        services:
          truenas:
            loadBalancer:
              servers:
              - url: "http://192.168.0.228/"
          photos:
            loadBalancer:
              servers:
              - url: "http://192.168.0.228:30041/"
          cloud:
            loadBalancer:
              servers:
              - url: "http://192.168.0.228:30027/"

        routers:
          truenas-router:
            rule: "Host(`nas.mnara.ca`)"
            entryPoints:
              - "websecure"
            service: "truenas"
            tls: {}
          photos-router:
            rule: "Host(`photos.mnara.ca`)"
            entryPoints:
              - "websecure"
            service: "photos"
            tls: {}
          cloud-router:
            rule: "Host(`cloud.mnara.ca`)"
            entryPoints:
              - "websecure"
            service: "cloud"
            tls: {}
      EOT
    }
  }
}
