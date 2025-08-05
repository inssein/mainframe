# resource "kubernetes_service_v1" "truenas" {
#   metadata {
#     name = "truenas"
#   }

#   spec {
#     port {
#       port        = 8080
#       target_port = 80
#       protocol    = "TCP"
#     }
#   }
# }

# resource "kubernetes_endpoints_v1" "truenas" {
#   metadata {
#     name = kubernetes_service_v1.truenas.metadata.0.name
#   }

#   subset {
#     address {
#       ip = "192.168.50.253"
#     }

#     port {
#       name     = "http"
#       port     = 80
#       protocol = "TCP"
#     }
#   }
# }

# resource "kubernetes_ingress_v1" "truenas" {
#   depends_on = [kubernetes_service_v1.truenas]
#   metadata {
#     name = "truenas"
#   }

#   spec {
#     tls {
#       secret_name = "wildcard-mnara-ca-tls"
#     }

#     rule {
#       host = "nas.mnara.ca"
#       http {
#         path {
#           backend {
#             service {
#               name = kubernetes_service_v1.truenas.metadata[0].name
#               port {
#                 number = 8080
#               }
#             }
#           }
#           path      = "/"
#           path_type = "Prefix"
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "truenas_traefik_service" {
#   depends_on = [kubernetes_service_v1.truenas]
#   manifest = {
#     "apiVersion" = "traefik.io/v1alpha1"
#     "kind"       = "TraefikService"
#     "metadata" = {
#       "name"      = "truenas-wrr-svc"
#       "namespace" = "default"
#     }
#     "spec" = {
#       "weighted" = {
#         "services" = [
#           {
#             "name"           = kubernetes_service_v1.truenas.metadata[0].name
#             "kind"           = "Service"
#             "port"           = 8080
#             "weight"         = 1
#             "passHostHeader" = true
#           }
#         ]
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "truenas_ingress_route" {
#   depends_on = [
#     kubernetes_endpoints_v1.truenas
#   ]

#   manifest = {
#     "apiVersion" = "traefik.io/v1alpha1"
#     "kind"       = "IngressRoute"
#     "metadata" = {
#       "name"      = "truenas-ingressroute"
#       "namespace" = "default"
#     }
#     "spec" = {
#       "entryPoints" = ["websecure"]
#       "routes" = [
#         {
#           "match" = "Host(`nas.mnara.ca`)"
#           "kind"  = "Rule"
#           "services" = [
#             {
#               "name" = "truenas-wrr-svc"
#               "kind" = "TraefikService"
#             }
#           ]
#         }
#       ]
#       "tls" = {
#         "secretName" = "wildcard-mnara-ca-tls"
#       }
#     }
#   }
# }

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

# resource "kubernetes_manifest" "truenas_ingress_route" {
#   depends_on = [
#     kubernetes_manifest.traefik_helmchartconfig
#   ]

#   manifest = {
#     "apiVersion" = "traefik.io/v1alpha1"
#     "kind"       = "IngressRoute"
#     "metadata" = {
#       "name"      = "truenas-ingressroute"
#       "namespace" = "default"
#     }
#     "spec" = {
#       "entryPoints" = ["websecure"]
#       "routes" = [
#         {
#           "match" = "Host(`nas.mnara.ca`)"
#           "kind"  = "Rule"
#           "services" = [
#             {
#               "name" = "truenas"
#               "kind" = "TraefikService"
#             }
#           ]
#         }
#       ]
#       "tls" = {
#         "secretName" = "wildcard-mnara-ca-tls"
#       }
#     }
#   }
# }
