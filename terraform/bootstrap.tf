
resource "null_resource" "bootstrap" {
  # todo: version is cumbersome, maybe we can move the commands
  # into a file and use a checksum of the file
  triggers = {
    version = "0.0.4"
  }

  for_each = local.nodes

  connection {
    type        = "ssh"
    user        = local.user
    private_key = file("~/.ssh/${local.private_key}")
    host        = each.value.hostname
  }

  provisioner "remote-exec" {
    inline = [
      # set timezone and enable NTP
      "sudo timedatectl set-timezone UTC",
      "sudo timedatectl set-ntp true",

      # enable cgroup
      "if ! grep -qP 'cgroup_memory=1' /boot/cmdline.txt; then sudo sed -i.bck '$s/$/ cgroup_memory=1/' /boot/cmdline.txt; fi",
      "if ! grep -qP 'cgroup_enable=memory' /boot/cmdline.txt; then sudo sed -i.bck '$s/$/ cgroup_enable=memory/' /boot/cmdline.txt; fi",

      # disable swap
      "sudo service dphys-swapfile stop",
      "sudo apt-get purge dphys-swapfile -y",

      # update the system
      "sudo apt-get update -y",
      "sudo apt-get -y --purge autoremove",

      # k3s does not support mDNS, ensure IP's don't change by setting a static ip
      "IP_ADDR=$(hostname -I | awk '{print $1}')",
      "ROUTER_ADDR=$(ip route show default | awk '{print $3}')",
      "if ! grep -qP '^interface eth0' /etc/dhcpcd.conf; then sudo echo -e \"\ninterface eth0\nstatic ip_address=$IP_ADDR/24\nstatic routers=$ROUTER_ADDR\nstatic domain_name_servers=8.8.8.8 $ROUTER_ADDR\" >> /etc/dhcpcd.conf; fi",

      # finally, reboot
      "sudo shutdown -r +0"
    ]
  }
}

# wait 90 seconds after the node(s) have rebooted before doing anything else
resource "time_sleep" "wait_90_seconds" {
  depends_on      = [null_resource.bootstrap]
  create_duration = "90s"
}

resource "null_resource" "next" {
  depends_on = [time_sleep.wait_90_seconds]
}