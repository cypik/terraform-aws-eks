terraform {
  required_version = ">= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.3.7"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}
