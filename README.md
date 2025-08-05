# Mainframe

This repository consists of software to run my homelab. Initially it was 4 Raspberry Pis, but I have recently added a much more powerful machine to run a NAS. It's not that the Pis couldn't do it, but I had them running on MicroSD cards (bad idea; unreliable), so I decided to add a capable machine into the mix with SSDs and HDDs.

## Goals

1. Learn Terraform
1. Learn Kubernetes
1. Run a few services in my home network (Home Assistant, AdGuard, maybe an app) that are currently running via other means.
1. Run a NAS.

## Setup

### Raspberry Pi
There is a little bit of manual work that needs to be done for each Pi.

1. Generate a new ssh key for communicating with the pi nodes: `ssh-keygen -t ed25519 -f ~/.ssh/mainframe -C "terraform@mainframe.local"`
1. Download Balena Etcher
1. Download the [DietPI .img](https://dietpi.com/downloads/images/DietPi_RPi-ARMv8-Bullseye.7z)
1. For each PI, grab the SD card, use Balena Etcher to flash the above image, and then replace `dietpi.txt` in the root of the SD Card with the one found in this repo. Lastly, adjust the hostname accordingly.

### NAS
I decided to run TrueNAS SCALE for the NAS portion of it, but not use it for any of its apps functionality and rely on my K3S setup.

This machine has 2x2TB NVMe drives that I am running in mirrored fashion. Unfortunately, TrueNAS likes to use the whole drive for the OS, which is a big waste of a 2TB NVMe drive. I decided to partition 256gb for the boot data and use the rest as storage by following this [guide](https://www.reddit.com/r/truenas/comments/lgf75w/scalehowto_split_ssd_during_installation/).

1. Download the ISO and use Balena Etcher to flash it to a USB drive.
1. Run the installer, go into the shell, edit `vi /usr/lib/python3/dist-packages/truenas_installer/install.py`, and adjust "await run(["sgdisk", "-n3:0:0", "-t3:BF01", disk.device])" to "await run(["sgdisk", "-n3:0:+256gb", "-t3:BF01", disk.device])". The only change was the +256gb.
1. Finish with the rest of the installer.
1. Open up the web interface, go into the shell and run:
  a. `sudo su`
  b. `sgdisk -n4:0:0 -t4:BF01 /dev/nvme0n1`
  c. `sgdisk -n4:0:0 -t4:BF01 /dev/nvme1n1`
  d. `partprobe`
  e. `fdisk -lx /dev/nvme0n1`
  f. `fdisk -lx /dev/nvme1n1`
  g. `zpool create -f ssd-storage mirror /dev/disk/by-partuuid/[uuid_from fdisk -lx disk1] /dev/disk/by-partuuid/[uuid_from fdisk -lx disk2]`
  h. `zpool export ssd-storage`
1. Go back into the Web UI, and import the storage pool.

## Automation

Terraform is used as much as possible for automation. It may not be perfectly suited for this task, but see goal #1.

Ensure terraform is installed by running:

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

The terraform automation is broken up into 3 stages (bootstrap, kubernetes, services), all explained in their respective README's.

### Updating K3S

This process is not automated yet, but you can SSH into each of the nodes and perform upgrades manually.

On the server, you can run `curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --secrets-encryption --disable local-storage --disable servicelb`, and on the agent, you can run `curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.27.6+k3s1 K3S_URL=https://192.168.50.22:6443 K3S_TOKEN=PRIVATE sh -`

## Networking

By default, nothing is exposed to the outside world as the router firewall blocks everything.

### Static IP

The cluster currently uses two hostnames: home.mnara.ca and ha.mnara.ca. The cluster is setup to run a task every 5 minutes to update the IP address incase it changes.

### HTTP(s)

Run `kubectl get ingress` to get the IP of the ingress service and then port-forward 80 and 443 so that those services are available externally.

### DNS

AdGuard Home will be exposed on 192.168.50.53 (hardcoded, can let it auto assign), and once its up, adjust the router settings to use that as the DNS.

## Home Assistant

Home assistant doesn't work without modifications to its configuration file, it complains about a reverse proxy error.

In order to fix this:
1. Figure out which node longhorn is using for its storage volume by going to https://longhorn.internal.mnara.ca, then go to the volumes tab and click on the home assistant volume. Somewhere on that page it should mention which mainframe node its on.
1. SSH into the node
1. Run `lsblk`
1. `cd` into the directory returned by `lsblk` (`cd /var/lib/kubelet/pods/9514a649-ebd0-4b6e-84ff-ad74a17f5a7f/...`)
1. Add the following configuration to `configuration.yaml`:
    ```
    http:
      server_host: 0.0.0.0
      ip_ban_enabled: true
      login_attempts_threshold: 5
      use_x_forwarded_for: true
      trusted_proxies:
        - 10.42.0.0/16
        - 192.168.0.0/16
    ```
1. Restart the home-assistant pod by scaling up and then down: `kubectl scale --replicas=0 deployment/home-assistant`

## Todo
1. Backup longhorn storage so we don't lose configuration for home-assistant and adguard.
1. Use wildcard cert in traefik and nginx by default. Currently doesn't seem to be a way to re-configure Traefik, so we would have to re-initialize k3s without traefik first.
1. Automate grabbing the kubernetes config from coordinator node.
1. Write a script that generates the DietPi configuration from some input parameters. Most of the information in the config is defaults, but DietPi doesn't work with a partial configuration.
