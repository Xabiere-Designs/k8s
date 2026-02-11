# configure kubectl with the cluster
aws eks update-kubeconfig --name <cluster name> -- region <region of cluster> 

# configure user access thru auth-configmap

kubectl get configmap -n kube-system

mapRoles:
----
- groups:
    - system:bootstrappers
    - system:nodes
    rolearn: arn:aws:iam::<account id>:role/<node instance role name>
    username: system:node:{{EC2PrivateDNSName}}
    - groups:
    - system:masters
    rolearn: arn:aws:iam::<account id>:role/<admin role name>
    username: admin
# create a node group
eksctl create nodegroup --cluster <cluster name> --name <node group name> --node-type <instance type> --nodes <number of nodes> --nodes-min <min number of nodes> --nodes-max <max number of nodes>
--managed
# delete a node group
eksctl delete nodegroup --cluster <cluster name> --name <node group name>
# delete the cluster
eksctl delete cluster --name <cluster name>
# view nodes
kubectl get nodes
# view pods in all namespaces
kubectl get pods --all-namespaces
# view services in all namespaces
kubectl get svc --all-namespaces
# view deployments in all namespaces
kubectl get deployments --all-namespaces
# view namespaces
kubectl get namespaces
# view cluster info
kubectl cluster-info
# view cluster events
kubectl get events --all-namespaces   



    