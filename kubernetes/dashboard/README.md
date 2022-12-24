# Kubernetes Dashboard

## Installation
1. Install dashboard: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`
1. Create a user: `kubectl create -f kubernetes/dashboard/admin-user.yml -f kubernetes/dashboard/admin-user-role.yml`
1. Grab token: `kubectl -n kubernetes-dashboard create token admin-user`
1. Start proxy: `kubectl proxy`
1. Go to [dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login)
1. Login to dashboard via token from step 3