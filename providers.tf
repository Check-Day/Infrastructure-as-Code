terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                    = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "iac"
}

provider "kubernetes" {
  config_path    = "/Users/saitejsunkara/.kube/config"
  config_context = "arn:aws:eks:us-east-1:467465390813:cluster/checkday_eks_cluster"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}