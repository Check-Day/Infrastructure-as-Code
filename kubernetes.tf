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

data "aws_ecr_authorization_token" "checkday_token" {
}

resource "kubernetes_secret" "checkday_ecr_secret" {
  metadata {
    name = "checkday-ecr-secret"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "467465390813.dkr.ecr.us-east-1.amazonaws.com" = {
          username = "AWS"
          password = data.aws_ecr_authorization_token.checkday_token.password
          email    = "sunkara.sai+checkday_dev@northeastern.edu"
          auth     = base64encode("AWS:${data.aws_ecr_authorization_token.checkday_token.password}")
        }
      }
    })
  }
}

resource "kubernetes_deployment" "checkday_k8_deployment" {
  metadata {
    name = "checkday-app-deployment"
    labels = {
      app = "checkday"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "checkday-app-tag"
      }
    }

    template {
      metadata {
        name = "checkday-app"
        labels = {
          app = "checkday-app-tag"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.checkday_ecr_secret.metadata[0].name
        }

        container {
          image = var.imageURI
          name  = "checkday-app"

          port {
            container_port = 5969
          }
        }
      }
    }
  }
}

variable "imageURI" {
  type = string
  description = "contains Imaage URI from AWS Container Registry"
  default = "467465390813.dkr.ecr.us-east-1.amazonaws.com/checkday:checkday-image"
}