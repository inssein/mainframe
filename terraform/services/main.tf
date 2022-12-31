terraform {
  backend "kubernetes" {
    secret_suffix = "services-state"
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

module "adguard" {
  source = "../modules/adguard"
}

module "home-assistant" {
  source = "../modules/home-assistant"
}

module "whoami" {
  source = "../modules/whoami"
}
