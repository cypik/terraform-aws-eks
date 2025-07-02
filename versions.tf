terraform {
  required_version = ">= 1.9.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.10.0, < 2.0.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}
