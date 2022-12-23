# Mainframe

This repository consists of software that runs on a Raspberry Pi Cluster.

## Goals

1. Learn Terraform
2. Learn Kubernetes
3. Run a few services in my home network (Home Assistant, AdGuard, maybe an app) that are currently running via other means.

## Setup

There is a little bit of manual work that needs to be done for each Pi.

1. Generate a new ssh key for communicating with the pi nodes: `ssh-keygen -t ed25519 -f ~/.ssh/mainframe -C "terraform@mainframe.local"`
1. Download Raspberry Pi Imager
1. For each pi, flash the "Raspberry PI OS Lite (64-Bit)"
    * Set a proper hostname (`mainframe-nXX`)
    * Enable SSH and paste the public key from step 1


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