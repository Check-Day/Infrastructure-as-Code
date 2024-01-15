provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
  }
}

resource "helm_release" "karpenter" {
    namespace = "karpenter"
    create_namespace = true

    name = "karpenter"
    repository = "https://charts.karpenter.sh"
    chart = "karpenter"
    version = "v0.16.3"

    set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.checkday_eks_karpenter_controller.arn
    }

    set {
        name  = "clusterName"
        value = aws_eks_cluster.checkday_eks_cluster.id
    }

    set {
        name  = "clusterEndpoint"
        value = aws_eks_cluster.checkday_eks_cluster.endpoint
    }

    set {
        name  = "aws.defaultInstanceProfile"
        value = aws_iam_instance_profile.karpenter.name
    }

    depends_on = [aws_eks_node_group.checkday_eks_private_nodes]
}