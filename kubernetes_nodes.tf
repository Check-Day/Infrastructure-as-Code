resource "aws_iam_role" "checkday_node_group_role" {
  name = "checkday_node_group_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
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

resource "aws_security_group" "checkday_worker_node_security_group" {
    name = "checkday_worker_node_security_group"
    description = "Allows SSH Inbound Traffic"
    vpc_id = aws_vpc.checkday_vpc.id

    ingress {
        description = "SSH access to Subnet"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eks_node_group" "checkday_eks_private_nodes" {
    cluster_name = aws_eks_cluster.checkday_eks_cluster.name
    node_group_name = "checkday_eks_private_nodes"
    node_role_arn = aws_iam_role.checkday_node_group_role.arn

    subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]

    capacity_type = "ON_DEMAND"
    instance_types = ["t3.small"]

    scaling_config {
        desired_size = 1
        max_size = 7
        min_size = 0
    }

    update_config {
        max_unavailable = 1
    }

    labels = {
        role = "general"
        node = "checkday_k8_node"
    }

    remote_access {
    ec2_ssh_key = aws_key_pair.checkday_generated_key_pair.key_name
    source_security_group_ids = [aws_security_group.checkday_worker_node_security_group.id]
  }

    depends_on = [
        aws_iam_role_policy_attachment.checkday_AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.checkday_AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.checkday_AmazonEC2ContainerRegistryReadOnly,
    ]
}

resource "kubernetes_deployment" "checkday_app" {
  metadata {
    name = "checkday-app-deployment"
    namespace = "default"
    labels = {
      app = "checkday-app"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "checkday-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "checkday-app"
        }
      }

      spec {
        image_pull_secrets {
          name = "checkday-docker-hub-secret"
        }

        container {
          name  = "checkday-pod"
          image = "saitejsunkara/checkday:checkday"
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "role"
                  operator = "In"
                  values   = ["general"]
                }
              }
            }
          }
        }
      }
    }
  }
}