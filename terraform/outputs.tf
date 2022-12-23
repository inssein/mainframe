output "k3s_token" {
  description = "Secret token used to join nodes to the cluster"
  value       = random_password.k3s_cluster_secret.result
  sensitive   = true
}