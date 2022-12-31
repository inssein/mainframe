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

Ensure terraform is installed by running:

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

The terraform automation is broken up into 3 stages (bootstrap, kubernetes, services), all explained in their respective README's.
