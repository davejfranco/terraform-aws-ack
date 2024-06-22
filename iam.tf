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
  for_each = { for k, v in var.controllers : k => v if var.eks == true }

  name               = "${each.key}-ack-role"
  assume_role_policy = data.aws_iam_policy_document.ack_assume_role[each.key].json
}

locals {

  inline_policy = { for k, v in var.controllers :
    k => file("${path.module}/files/${k}/inline-policy.json")
  if fileexists("${path.module}/files/${k}/inline-policy.json") }

  recommended_policy = { for k, v in var.controllers :
    k => file("${path.module}/files/${k}/recommended-policy")
  if fileexists("${path.module}/files/${k}/recommended-policy") }

}

resource "aws_iam_policy" "this" {
  for_each = var.eks == true ? local.inline_policy : {}

  name        = "${each.key}-ack-policy"
  description = "IAM policy to allow ack ${each.key} controller to manage resources aws resources"
  policy      = each.value
}

resource "aws_iam_role_policy_attachment" "this_inline" {
  for_each = { for k, v in var.controllers : k => v if var.eks == true }

  role       = aws_iam_role.ack[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "aws_iam_role_policy_attachment" "this_recommended" {
  for_each = var.eks == true ? local.recommended_policy : {} 

  role       = aws_iam_role.ack[each.key].name
  policy_arn = each.value
}

