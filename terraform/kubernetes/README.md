# Kubernetes

This stage sets up the kubernetes cluster with the systems level services that are needed (networking, storage, etc).

The state file is backed up in the kubernetes cluster itself, so if we lose the cluster, we lose the state.

## Run the automation
1. `terraform init`
2. `terraform apply`
