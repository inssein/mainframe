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

We are going to use Terraform as much as possible for automation. It may not be perfectly suited for this task, but see goal #1.

The rest of the steps assumes you are in the `terraform` directory.

1. Install terraform
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ```
1. Run `terraform init`
1. Run `terraform apply`

You should now have a fully working k3s cluster.

## Kubernetes

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/) on local machine.
1. Grab the k3s configuration file from the coordinator node and place it in `~/.kube/config`. The configuration file can be found on mainframe-n01:/etc/rancher/k3s/k3s.yaml. Make sure to point to the ip address of the coordinator node (not hostname as k3s doesn't support mDNS), and optionally rename the contexts / admin user.

## ToDo

1. There is a dependency in terraform between creating the cluster and running kubernetes as the config is required. Separate them out.