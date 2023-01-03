terraform {
  backend "kubernetes" {
    secret_suffix = "state"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

# setup networking - metallb
module "metallb" {
  source = "../modules/metallb"
}

# setup internal load balancer
resource "kubernetes_service_v1" "traefik_internal" {
  metadata {
    name      = "traefik-internal"
    namespace = "kube-system"
  }

  spec {
    allocate_load_balancer_node_ports = true
    ip_family_policy                  = "PreferDualStack"
    session_affinity                  = "None"
    ip_families                       = ["IPv4"]
    external_traffic_policy           = "Cluster"
    internal_traffic_policy           = "Cluster"
    type                              = "LoadBalancer"

    port {
      name        = "web"
      protocol    = "TCP"
      port        = 80
      target_port = "web"
    }

    port {
      name        = "websecure"
      protocol    = "TCP"
      port        = 443
      target_port = "websecure"
    }

    selector = {
      "app.kubernetes.io/name" = "traefik"
    }
  }
}

# setup storage - longhorn
module "longhorn" {
  source = "../modules/longhorn"
  nodes  = toset([for each in data.terraform_remote_state.bootstrap.outputs.nodes : each.hostname])
}

# setup secrets management
module "sealed-secrets" {
  source = "../modules/sealed-secrets"
}