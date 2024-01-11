resource "aws_eks_cluster" "checkday_eks_cluster" {
  name = "checkday_eks_cluster"
  role_arn = aws_iam_role.checkday_eks_master.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]

}

resource "aws_eks_node_group" "checkday_eks_node_group" {
  cluster_name    = aws_eks_cluster.checkday_eks_cluster.name
  node_group_name = "checkday-node"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]
  capacity_type = "ON_DEMAND"
  disk_size = "30"
  instance_types = ["t2.small"]
  remote_access {
    ec2_ssh_key = aws_key_pair.checkday_generated_key_pair.key_name
    source_security_group_ids = [aws_security_group.checkday_worker_node_security_group.id]
  } 
  
  labels =  tomap({env = "dev"})
  
  scaling_config {
    desired_size = 2
    max_size     = 7
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}