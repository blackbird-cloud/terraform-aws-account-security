module "config" {
  source         = "./bucket"
  purpose        = "config"
  bucket_prefix  = "${var.aws_account_name}-config"
  iam_principals = [aws_iam_role.config.arn]
  object_actions = []
  kms_actions = [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:DescribeKey",
  ]
  logging = {
    target_bucket = module.accesslogs.bucket.s3_bucket_id
    target_prefix = "config"
  }
}

resource "aws_config_configuration_recorder" "config" {
  name     = "config-recorder-${var.aws_account_name}"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_securityhub_account.account]
}

resource "aws_config_delivery_channel" "config" {
  name           = "config-delivery-${var.aws_account_name}"
  s3_kms_key_arn = module.config.kms.arn
  s3_bucket_name = module.config.bucket.s3_bucket_id
  s3_key_prefix  = "config"
  sns_topic_arn  = aws_sns_topic.config.arn

  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.config]
}

# Config recorder rules
# https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
# https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html
# https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs
resource "aws_config_conformance_pack" "cis" {
  name = "CIS"

  template_body = <<EOT
${file("${path.module}/conformance-packs/Operational-Best-Practices-for-CIS.yaml")}
EOT

  depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_conformance_pack" "databases" {
  name = "Databases"

  template_body = <<EOT
${file("${path.module}/conformance-packs/Operational-Best-Practices-for-Database-Services.yaml")}
EOT

  depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_conformance_pack" "s3" {
  name = "S3"

  template_body = <<EOT
${file("${path.module}/conformance-packs/Operational-Best-Practices-for-Amazon-S3.yaml")}
EOT

  depends_on = [aws_config_configuration_recorder.config]
}
