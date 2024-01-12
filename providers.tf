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
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}