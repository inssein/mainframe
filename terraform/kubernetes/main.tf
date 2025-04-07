terraform {
  backend "kubernetes" {
    secret_suffix  = "state"
    config_path    = "~/.kube/config"
    config_context = "mainframe"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "mainframe"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "mainframe"
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

# setup internal ingress controller (using nginx)
module "ingress-nginx" {
  source = "../modules/ingress-nginx"
}

# traefik dashboard
module "traefik-dashboard" {
  source = "../modules/traefik-dashboard"
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

# tls certs
module "cert-manager" {
  source = "../modules/cert-manager"
}

# monitoring
# module "monitoring" {
#   source = "../modules/monitoring"
# }
