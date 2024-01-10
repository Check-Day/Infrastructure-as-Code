resource "aws_eks_cluster" "checkday_eks_cluster" {
  name     = "checkday_eks_cluster"
  role_arn = aws_iam_role.checkday_eks_role.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.checkday-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.checkday-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.checkday_eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.checkday_eks_cluster.certificate_authority[0].data
}