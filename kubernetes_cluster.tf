resource "aws_iam_role" "checkday_eks_master" {
    name = "checkday_eks_master"
assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "checkday_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.checkday_eks_master.name
}

resource "aws_eks_cluster" "checkday_eks_cluster" {
  name = "checkday_eks_cluster"
  role_arn = aws_iam_role.checkday_eks_master.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.checkday_AmazonEKSClusterPolicy,
  ]

}