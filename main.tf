
resource "null_resource" "helm_login" {

  provisioner "local-exec" {
    command = "aws ecr-public get-login-password --region ${var.aws_region} | helm registry login --username AWS --password-stdin public.ecr.aws"
  }
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "this" {
  count = var.eks ? 0 : 1

  metadata {
    name      = "aws-creds"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }

  data = {
    credentials = file(var.aws_credentials_file)
  }
}


# AWS Related 
resource "helm_release" "this" {
  for_each   = var.controllers
  name       = each.key
  namespace  = kubernetes_namespace_v1.this.metadata.0.name
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart      = "${each.key}-chart"
  version    = each.value.version

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  dynamic "set" {
    for_each = var.eks ? [0] : [1]
    content {
      name  = "aws.credentials.secretName"
      value = "aws-creds"
    }
  }

  dynamic "set" {
    for_each = var.eks ? [0] : [1]
    content {
      name  = "aws.credentials.secretKey"
      value = "credentials"
    }
  }

  dynamic "set" {
    for_each = var.eks ? [0] : [1]
    content {
      name  = "aws.credentials.profile"
      value = var.aws_profile
    }
  }

  depends_on = [
    null_resource.helm_login,
    kubernetes_secret_v1.this
  ]
}

