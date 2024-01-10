data "aws_iam_policy_document" "checkday_eks_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "checkday_eks_role" {
  name               = "checkday_eks_role"
  assume_role_policy = data.aws_iam_policy_document.checkday_eks_role_policy.json
}

resource "aws_iam_role_policy_attachment" "checkday-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.checkday_eks_role.name
}

resource "aws_iam_role_policy_attachment" "checkday-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.checkday_eks_role.name
}