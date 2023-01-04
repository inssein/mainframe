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

# setup internal ingress controller (using nginx)
module "ingress-nginx" {
  source = "../modules/ingress-nginx"
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