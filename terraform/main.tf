resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}