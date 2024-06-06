

resource "null_resource" "helm_login" {

  provisioner "local-exec" {
    command = "aws ecr-public get-login-password --region ${var.aws_region} | helm registry login --username AWS --password-stdin public.ecr.aws"
  }
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "ack-system"
  }
}

resource "helm_release" "s3" {
  count      = var.s3 ? 1 : 0
  name       = "s3-controller"
  namespace  = kubernetes_namespace_v1.this.metadata.0.name
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart      = "s3-chart"
  version    = "1.0.12"

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  set {
    name  = "aws.credentials.secretName"
    value = "aws-creds"
  }

  set {
    name  = "aws.credentials.secretKey"
    value = "credentials"
  }

  set {
    name  = "aws.credentials.profile"
    value = "default"
  }
  depends_on = [
    null_resource.helm_login
  ]
}

resource "helm_release" "ec2" {
  count      = var.ec2 ? 1 : 0
  name       = "ec2-controller"
  namespace  = kubernetes_namespace_v1.this.metadata.0.name
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart      = "ec2-chart"
  version    = "1.0.12"

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  set {
    name  = "aws.credentials.secretName"
    value = "aws-creds"
  }

  set {
    name  = "aws.credentials.secretKey"
    value = "credentials"
  }

  set {
    name  = "aws.credentials.profile"
    value = "default"
  }
  depends_on = [
    null_resource.helm_login
  ]
}

