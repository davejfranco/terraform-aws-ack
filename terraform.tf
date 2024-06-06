terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-local"
}

provider "helm" {

  kubernetes {
    config_path = "~/.kube/config"
    //exec {
    //  api_version = "client.authentication.k8s.io/v1alpha1"
    //  args        = ["ecr-public", "get-login-password", "--region", "us-east-1"]
    //  command     = "aws"
    //}
  }

  //registry {
  //  url      = "public.ecr.aws"
  //  username = "AWS"
  //  password = "password"
  //}
}
