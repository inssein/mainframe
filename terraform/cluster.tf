# coordinator node
resource "null_resource" "gru" {
  depends_on = [null_resource.next]

  connection {
    type        = "ssh"
    user        = local.user
    private_key = file("~/.ssh/${local.private_key}")
    host        = local.gru
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_cluster_secret.result} sh -",
    ]
  }
}

# grab ip of coordinator node since k3s doesn't support mDNS
data "dns_a_record_set" "gru" {
  host = local.gru
}

locals {
  gru_addr = one(data.dns_a_record_set.gru.addrs)
}

# worker nodes
resource "null_resource" "minions" {
  depends_on = [null_resource.gru]

  for_each = local.minions

  connection {
    type        = "ssh"
    user        = local.user
    private_key = file("~/.ssh/${local.private_key}")
    host        = each.value
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${local.gru_addr}:6443 K3S_TOKEN=${random_password.k3s_cluster_secret.result} sh -",
    ]
  }
}