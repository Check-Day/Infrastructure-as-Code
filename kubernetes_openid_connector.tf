data "tls_certificate" "checkday_tls_certificate_for_eks" {
    url = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "checkday_openid_connector" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.checkday_tls_certificate_for_eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "checkday_oidc_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${aws_iam_openid_connect_provider.checkday_openid_connector.url}:aud"
            values = ["system:serviceaccount:karpenter:checkday-k8-account"]
        }

        principals {
            identifiers = [aws_iam_openid_connect_provider.checkday_openid_connector.arn]
            type = "Federated"
        }
    }
}

resource "aws_iam_role" "checkday_karpenter_controller_role" {
    assume_role_policy = data.aws_iam_policy_document.checkday_oidc_assume_role_policy.json
    name = "checkday_karpenter_controller"
}

resource "aws_iam_policy" "karpenter_controller_policy" {
    policy = file("./karpenter-controller-trust-policy.json")
    name = "KarpenterController"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
    role = aws_iam_role.checkday_karpenter_controller_role.name
    policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

resource "aws_iam_instance_profile" "checkday_karpenter_instance_profile" {
    name = "KarpenterNodeInstanceProfile"
    role = aws_iam_role.checkday_node_group_role.name
}