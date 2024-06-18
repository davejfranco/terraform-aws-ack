# ACK IAM Role
data "aws_iam_policy_document" "ack_assume_role" {
  for_each = { for k, v in var.controllers : k => v if var.eks == true }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.namespace}:${each.key}"]
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role" "ack" {
  for_each           = var.controllers
  name               = "${each.key}-ack-role"
  assume_role_policy = data.aws_iam_policy_document.ack_assume_role[each.key].json
}







