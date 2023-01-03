# Bootstrap

This stage probably makes the least sense to be in Terraform because it is mostly running SSH commands on the nodes to get them ready and get them to form a kubernetes cluster.

## State
The statefile is saved in git, which is generally a bad idea because sensitive tokens are included in plaintext such as the `K3S_TOKEN`.

For this project, I didn't want to create a cloud account on AWS or GCP just to store this file. Additionally, the only secret exposed is the K3S server token which would allow other nodes to join the cluster, but only in the local home network as the cluster is not exposed.

## Run the automation
1. `terraform init`
2. `terraform apply`

## Configuration
After the bootstrap is run, you should have a running k3s cluster. To make changes locally, you need to grab `mainframe-n01:/etc/rancher/k3s/k3s.yaml` and save it as `~/.kube/config`.

## Todo
1. Waiting for 90s for restart to be complete seems silly - try connecting to SSH? Terraform by default keeps trying.