provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "whoami" {
  source         = "../../"
  name           = "whoami"
  num_replicas   = 2
  namespace_name = var.namespace_name
}
