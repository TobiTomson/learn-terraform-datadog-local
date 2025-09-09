terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50.0"
    }

    tfe = {
      source = "hashicorp/tfe"
      version = ">= 0.42.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
  }
  required_version = ">= 1.10.0"
}

provider "aws" {
  region = "us-east-2"
}
