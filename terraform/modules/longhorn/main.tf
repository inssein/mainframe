resource "null_resource" "iscsi" {
  for_each = var.nodes

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("~/.ssh/${var.private_key}")
    host        = each.value
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install open-iscsi -y"
    ]
  }
}

resource "helm_release" "longhorn" {
  depends_on       = [null_resource.iscsi]
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  version          = "1.3.2"
  create_namespace = true
}