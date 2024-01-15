kubectl config delete-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
aws configure --profile iac

aws eks update-kubeconfig --region us-east-1 --name checkday_eks_cluster --profile iac
kubectl config get-contexts
kubectl config use-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
kubectl get nodes
kubectl get pods
kubectl describe namespaces
kubectl create namespace karpenter

kubectl create secret docker-registry checkday-ecr-secret --docker-server=467465390813.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password) --docker-email=sunkara.sai+checkday_dev@northeastern.edu
kubectl create secret docker-registry checkday-docker-hub-secret --docker-username=saitejsunkara --docker-password=Encrypted@1729 --docker-email=sunkara.sai@northeastern.edu

helm repo add karpenter https://charts.karpenter.sh
helm repo update

helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --version v0.13.1 \
  --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::467465390813:role/karpenter-controller \
  --set clusterName=checkday_eks_cluster \
  --set clusterEndpoint=https://192B652310FCF97DA8D10E90A57CBD9D.gr7.us-east-1.eks.amazonaws.com \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile

helm list -n karpenter
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

