variable "aws_region" {
  type        = string
  description = "AWS region to deploy controllers"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = ""
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use"
  default     = "default"
}

variable "aws_credentials_file" {
  type        = string
  description = "Path to the AWS credentials file"
  default     = "~/.aws/credentials"
}

variable "eks" {
  type        = bool
  description = "If ACK is deployed on EKS"
  default     = false
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy controllers"
  default     = "ack-system"
}

variable "controllers" {
  type = map(object({
    version = string
  }))
  description = "List of controllers to deploy"

  validation {
    condition     = length(var.controllers) > 0
    error_message = "At least one controller must be enabled"
  }

  validation {
    condition = anytrue([
      for k in keys(var.controllers) : contains(["s3", "ec2", "rds"], k)
    ])
    error_message = "Controller not supported or does not exist"
  }

}
