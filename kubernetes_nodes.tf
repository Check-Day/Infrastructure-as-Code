resource "aws_iam_role" "checkday_node_group_role" {
  name = "checkday_node_group_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "checkday_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.checkday_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "checkday_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.checkday_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "checkday_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.checkday_node_group_role.name
}

resource "aws_eks_node_group" "checkday_eks_private_nodes" {
  cluster_name    = aws_eks_cluster.checkday_eks_cluster.name
  node_group_name = "checkday_eks_private_nodes"
  node_role_arn   = aws_iam_role.checkday_node_group_role.arn

  subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 7
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
        aws_iam_role_policy_attachment.checkday_AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.checkday_AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.checkday_AmazonEC2ContainerRegistryReadOnly,
    ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}