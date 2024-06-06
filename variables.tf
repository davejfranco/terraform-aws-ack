variable "aws_region" {
  type        = string
  description = "AWS region to deploy controllers"
  default     = "us-east-1"
}

variable "available_controllers" {
  type        = list(string)
  description = "List of available controllers"
  default     = ["s3"]
}

variable "s3" {
  type        = bool
  description = "Enable S3 Controller"
  default     = false
}


variable "ec2" {
  type        = bool
  description = "Enable ec2 Controller"
  default     = false
}
