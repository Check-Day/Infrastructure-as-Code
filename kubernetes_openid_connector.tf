data "tls_certificate" "checkday_tls_certificate_for_eks" {
    url = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "checkday_openid_connector" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.checkday_tls_certificate_for_eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.checkday_eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${aws_iam_openid_connect_provider.checkday_openid_connector.url}:aud"
            values = ["system:serviceaccount:default:checkday-k8-account"]
        }

        principals {
            identifiers = [aws_iam_openid_connect_provider.checkday_openid_connector.arn]
            type = "Federated"
        }
    }
}

resource "aws_iam_role" "checkday_test_oidc" {
    assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
    name = "checkday_test_oidc"
}

resource "aws_iam_policy" "checkday_test_policy" {
    name = "checkday_test_policy"

    policy = jsonencode({
        Statement = [{
            Action = [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ]
            Effect = "Allow"
            Resource = "arn:aws:s3:::*"
        }]
        Version = "2012-10-17"
    })
}

resource "aws_iam_role_policy_attachment" "checkday_test_attach" {
    role = aws_iam_role.checkday_test_oidc.name
    policy_arn = aws_iam_policy.checkday_test_policy.arn
}