# Mainframe

This repository consists of software that runs on a Raspberry Pi Cluster.

## Goals

1. Learn Terraform
2. Learn Kubernetes
3. Run a few services in my home network (Home Assistant, AdGuard, maybe an app) that are currently running via other means.

## Setup

There is a little bit of manual work that needs to be done for each Pi.

1. Generate a new ssh key for communicating with the pi nodes: `ssh-keygen -t ed25519 -f ~/.ssh/mainframe -C "terraform@mainframe.local"`
1. Download Balena Etcher
1. Download the [DietPI .img](https://dietpi.com/downloads/images/DietPi_RPi-ARMv8-Bullseye.7z)
1. For each PI, grab the SD card, use Balena Etcher to flash the above image, and then replace `dietpi.txt` in the root of the SD Card with the one found in this repo. Lastly, adjust the hostname accordingly.


## Automation

Terraform is used as much as possible for automation. It may not be perfectly suited for this task, but see goal #1.

Ensure terraform is installed by running:

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

The terraform automation is broken up into 3 stages (bootstrap, kubernetes, services), all explained in their respective README's.

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
