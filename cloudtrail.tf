data "aws_iam_policy_document" "cloudtrail_kms" {
  statement {
    sid       = "Full permissions for root"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", local.account_id)
      ]
    }
  }
  statement {
    sid       = "Allow KMS Use by Cloudtrail"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS Key for AWS Cloudtrail"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.cloudtrail_kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "cloudtrail" {
  target_key_id = aws_kms_key.cloudtrail.id
  name          = "alias/cloudtrail_key"
}

module "cloudtrail" {
  source             = "./bucket"
  purpose            = "cloudtrail"
  bucket_prefix      = "${var.aws_account_name}-cloudtrail"
  service_principals = ["cloudtrail.amazonaws.com"]
  kms_actions = [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:DescribeKey",
  ]
  bucket_actions = ["s3:GetBucketAcl"]
  logging = {
    target_bucket = module.accesslogs.bucket.s3_bucket_id
    target_prefix = "cloudtrail"
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_kms" {
  statement {
    sid       = "Full permissions for root"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", local.account_id)]
    }
  }
  statement {
    sid    = "Allow KMS Use by Cloudtrail Log Role"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ct_role.arn]
    }
  }
  statement {
    sid    = "Allow KMS Use by Cloudwatch Service"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "cloudtrail_cloudwatch" {
  description             = "KMS Key for AWS Cloudtrail Cloudwatch"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.cloudtrail_cloudwatch_kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "cloudtrail_cloudwatch" {
  target_key_id = aws_kms_key.cloudtrail_cloudwatch.id
  name          = "alias/cloudtrail_cloudwatch"
}

## CloudWatch
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name_prefix = "cloudtrail"
  kms_key_id  = aws_kms_key.cloudtrail_cloudwatch.arn
}

## IAM
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ct_role" {
  name               = "Cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy" {
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:*"
    ]
  }
}

resource "aws_iam_policy" "ct_role_policy" {
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_policy.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.ct_role_policy.arn
  roles = [
    aws_iam_role.ct_role.name
  ]
}

resource "aws_cloudtrail" "cloudtrail" {
  name           = "cloudtrail"
  enable_logging = true

  s3_bucket_name                = module.cloudtrail.bucket.s3_bucket_id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  cloud_watch_logs_role_arn  = aws_iam_role.ct_role.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
}
