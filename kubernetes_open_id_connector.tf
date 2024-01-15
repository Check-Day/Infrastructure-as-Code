# IAM Role for Service Accounts

data "tls_certificate" "checkday_eks_cluster_tls_certificate" {
    url = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "checkday_service_account_openid_connector" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.checkday_eks_cluster_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

# Karpenter Controller Role

data "aws_iam_policy_document" "checkday_karpenter_controller_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.checkday_service_account_openid_connector.url, "https://", "")}:sub"
            values = ["system:serviceaccount:karpenter:karpenter"]
            # Namespace = karpenter | Service Account Name = karpenter
        }

        principals {
            identifiers = [aws_iam_openid_connect_provider.checkday_service_account_openid_connector.arn]
            type = "Federated"
        }
    }
}

resource "aws_iam_role" "checkday_eks_karpenter_controller" {
    assume_role_policy = data.aws_iam_policy_document.checkday_karpenter_controller_assume_role_policy.json
    name = "karpenter-controller"
}

resource "aws_iam_policy" "checkday_eks_karpenter_controller_policy" {
    policy = file("./policies/controller-trust-policy.json")
    name = "KarpenterController"
}

resource "aws_iam_role_policy_attachment" "checkday_eks_karpenter_controller_policy_attach" {
    role = aws_iam_role.checkday_eks_karpenter_controller.name
    policy_arn = aws_iam_policy.checkday_eks_karpenter_controller_policy.arn
}

resource "aws_iam_instance_profile" "karpenter" {
    name = "CheckdayKarpenterNodeInstanceProfile"
    role = aws_iam_role.checkday_node_group_role.name
}