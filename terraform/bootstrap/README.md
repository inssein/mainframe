# Bootstrap

This stage probably makes the least sense to be in Terraform because it is mostly running SSH commands on the nodes to get them ready and get them to form a kubernetes cluster.

It also doesn't have its state file backed up anywhere, which means if I need to add nodes later and I don't have the previous state file, it might just be better to manually run the commands on the new node.

If in case that happens, the k3s token can be found at `mainframe-n01:/var/lib/rancher/k3s/server/node-token`.

## Configuration
After the bootstrap is run, you should have a running k3s cluster. To make changes locally, you need to grab `mainframe-n01:/etc/rancher/k3s/k3s.yaml` and save it as `~/.kube/config`.

## Todo
1. Save the statefile somewhere appropriate or change this to not be in terraform.
2. Waiting for 90s for restart to be complete seems silly - try connecting to SSH? Terraform by default keeps trying.