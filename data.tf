data "aws_caller_identity" "current" {}

locals {
  account_id                      = data.aws_caller_identity.current.account_id
  sns_topic_principal_identifiers = ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid = "GrantPublishForServices"

    actions   = ["sns:Publish"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = local.sns_topic_principal_identifiers
    }
  }
}

data "aws_iam_policy_document" "config_sns" {
  statement {
    sid = "GrantPublishForServices"

    actions   = ["sns:Publish"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.config.arn]
    }
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid = "Full permissions for root"

    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:aws:iam::%s:root", local.account_id)
      ]
    }
  }
  statement {
    sid    = "Allow KMS Use"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = concat(local.sns_topic_principal_identifiers,
        [
          "chatbot.amazonaws.com",
      ])
    }
  }
}
