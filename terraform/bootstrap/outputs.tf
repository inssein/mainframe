output "k3s_token" {
  description = "Secret token used to join nodes to the cluster"
  value       = random_password.k3s_cluster_secret.result
  sensitive   = true
}

output "nodes" {
  description = "List of nodes in the cluster"
  value       = var.nodes
}

output "gru" {
  description = "Hostname of the coordinator node"
  value       = local.gru
}

output "minions" {
  description = "Hostnames of the worker nodes"
  value       = local.minions
}