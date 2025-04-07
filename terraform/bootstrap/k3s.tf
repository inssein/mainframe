# pre-generate a token for the k3s installation
resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}

# coordinator node
resource "null_resource" "gru" {
  depends_on = [null_resource.next]

  connection {
    type        = "ssh"
    user        = local.gru.ssh_user
    private_key = file("~/.ssh/${var.private_key}")
    host        = local.gru.hostname
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.32.3+k3s1 sh -s - --token=${random_password.k3s_cluster_secret.result} --write-kubeconfig-mode 644 --secrets-encryption --disable local-storage --disable servicelb",
    ]
  }
}

# grab ip of coordinator node since k3s doesn't support mDNS
data "dns_a_record_set" "gru" {
  host = local.gru.hostname
}

# worker nodes
resource "null_resource" "minions" {
  depends_on = [null_resource.gru]

  for_each = { for node in local.minions : node.hostname => node }

  connection {
    type        = "ssh"
    user        = each.value.ssh_user
    private_key = file("~/.ssh/${var.private_key}")
    host        = each.value.hostname
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.32.3+k3s1 K3S_URL=https://${one(data.dns_a_record_set.gru.addrs)}:6443 K3S_TOKEN=${random_password.k3s_cluster_secret.result} sh -",
    ]
  }
}
