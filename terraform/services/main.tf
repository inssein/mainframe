terraform {
  backend "kubernetes" {
    secret_suffix  = "services-state"
    config_path    = "~/.kube/config"
    config_context = "default"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "default"
  }
}

module "adguard" {
  source = "../modules/adguard"
}

module "home-assistant" {
  source = "../modules/home-assistant"
}

module "home-bridge" {
  source = "../modules/home-bridge"
}

module "whoami" {
  source             = "../modules/whoami"
  name               = "whoami"
  num_replicas       = 3
  ingress_class_name = "traefik"
  tls_secret_name    = "wildcard-mnara-ca-tls"
  host               = "home.mnara.ca"
}

module "uptime-kuma" {
  source = "../modules/uptime-kuma"
}

module "matter-server" {
  source = "../modules/matter-server"
}
