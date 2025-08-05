resource "helm_release" "adguard" {
  name       = "adguard"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "adguard-home"
  values     = [templatefile("${path.module}/values.yaml", {})]
}

resource "kubernetes_service" "dns-tcp" {
  metadata {
    name = "adguard-dns-tcp"
    annotations = {
      "metallb.universe.tf/allow-shared-ip" = "adguard-dns"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "adguard-home"
    }

    type             = "LoadBalancer"
    load_balancer_ip = "192.168.0.53"

    port {
      port        = 53
      target_port = 53
      protocol    = "TCP"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["metallb.io/ip-allocated-from-pool"],
    ]
  }
}

resource "kubernetes_service" "dns-udp" {
  metadata {
    name = "adguard-dns-udp"
    annotations = {
      "metallb.universe.tf/allow-shared-ip" = "adguard-dns"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "adguard-home"
    }

    type             = "LoadBalancer"
    load_balancer_ip = "192.168.0.53"

    port {
      port        = 53
      target_port = 53
      protocol    = "UDP"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["metallb.io/ip-allocated-from-pool"],
    ]
  }
}

resource "kubernetes_ingress_v1" "adguard-dashboard" {
  metadata {
    name      = "adguard-dashboard"
    namespace = "default"
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      secret_name = "wildcard-internal-mnara-ca-tls"
    }

    rule {
      host = "adguard.internal.mnara.ca"
      http {
        path {
          backend {
            service {
              name = "adguard-adguard-home"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
