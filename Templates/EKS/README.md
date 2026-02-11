# configure kubectl with the cluster
aws eks update-kubeconfig --name <cluster name> -- region <region of cluster> 

# configure user access thru auth-configmap

kubectl get configmap -n kube-system