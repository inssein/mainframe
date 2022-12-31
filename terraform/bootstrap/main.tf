resource "null_resource" "bootstrap" {
  # todo: version is cumbersome, maybe we can move the commands
  # into a file and use a checksum of the file
  triggers = {
    version = "0.0.6"
  }

  for_each = { for n in var.nodes : n.hostname => n }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("~/.ssh/${var.private_key}")
    host        = each.value.hostname
  }

  provisioner "remote-exec" {
    inline = [
      # enable cgroup
      "if ! grep -qP 'cgroup_memory=1' /boot/cmdline.txt; then sudo sed -i.bck '$s/$/ cgroup_memory=1/' /boot/cmdline.txt; fi",
      "if ! grep -qP 'cgroup_enable=memory' /boot/cmdline.txt; then sudo sed -i.bck '$s/$/ cgroup_enable=memory/' /boot/cmdline.txt; fi",

      # reboot
      "sudo shutdown -r +0"
    ]
  }
}

# wait 90 seconds after the node(s) have rebooted before doing anything else
# todo: there must be a better way to check when the instance is back up
resource "time_sleep" "wait_90_seconds" {
  depends_on      = [null_resource.bootstrap]
  create_duration = "90s"
}

resource "null_resource" "next" {
  depends_on = [time_sleep.wait_90_seconds]
}