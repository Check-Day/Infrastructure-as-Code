kubectl config delete-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
aws configure --profile iac
kubectl rollout restart deployment checkday-app-deployment

aws eks update-kubeconfig --region us-east-1 --name checkday_eks_cluster --profile iac
kubectl config get-contexts
kubectl config use-context arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster
kubectl describe namespaces
kubectl create namespace karpenter
kubectl describe namespaces
kubectl create secret docker-registry checkday-ecr-secret --docker-server=467465390813.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password) --docker-email=sunkara.sai+checkday_dev@northeastern.edu
kubectl create secret docker-registry checkday-docker-hub-secret --docker-username=saitejsunkara --docker-password=Encrypted@1729 --docker-email=sunkara.sai@northeastern.edu


kubectl get nodes
kubectl get pods
kubectl apply -f kubernetes/karpenter_provisioner.yaml
helm list -A
kubectl get pods -n karpenter


kubectl describe deployment karpenter -n karpenter



# 2 Shells

kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
--
watch -n 1 -t kubectl get pods
watch -n 1 -t kubectl get nodes

    -
--
kubectl get secrets
kubectl apply -f kubernetes/k8.yaml

--------------------------
--------------------------
--------------------------
--------------------------
# Create SSL request in certificate manager and use it in load balancer
kubectl apply -f kubernetes/load_balancer.yaml

aws elbv2 describe-load-balancers
aws elbv2 describe-load-balancers --names a36b2ec827dfd45dc82cf718baa8b70c

a_record.tf should be run after creating load balancer with kubectl service