kubectl config delete-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
aws configure --profile iac

aws eks update-kubeconfig --region us-east-1 --name checkday_eks_cluster --profile iac
kubectl config get-contexts
kubectl config use-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
kubectl get nodes
kubectl get pods
kubectl describe namespaces
kubectl create namespace karpenter
helm list -A
kubectl get pods -n karpenter

kubectl create secret docker-registry checkday-ecr-secret --docker-server=467465390813.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password) --docker-email=sunkara.sai+checkday_dev@northeastern.edu
kubectl create secret docker-registry checkday-docker-hub-secret --docker-username=saitejsunkara --docker-password=Encrypted@1729 --docker-email=sunkara.sai@northeastern.edu


kubectl get pods -n karpenter
kubectl describe deployment karpenter -n karpenter

kubectl apply -f kubernetes/karpenter_provisioner.yaml

# 2 Shells

kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
--
watch -n 1 -t kubectl get pods
watch -n 1 -t kubectl get nodes

    -
--
kubectl get secrets
kubectl apply -f kubernetes/k8.yaml

