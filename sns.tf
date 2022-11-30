resource "aws_kms_key" "backup" {
  description             = "KMS Key for AWS Eventbridge Backup"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup_alias" {
  target_key_id = aws_kms_key.backup.id
  name          = "alias/eventbridge_backup"
}
resource "aws_sns_topic" "backup" {
  name              = var.backup_topic_name
  display_name      = "SNS topic for AWS Eventbridge Backup"
  kms_master_key_id = aws_kms_key.backup.arn
  policy            = data.aws_iam_policy_document.sns.json

  tags = merge(var.tags, {
    Name = var.backup_topic_name
  })
}

resource "aws_kms_key" "health" {
  description             = "KMS Key for AWS Eventbridge health"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "health_alias" {
  target_key_id = aws_kms_key.health.id
  name          = "alias/eventbridge_health"
}

resource "aws_sns_topic" "health" {
  name              = var.health_topic_name
  display_name      = "SNS topic for AWS Eventbridge health"
  kms_master_key_id = aws_kms_key.health.arn
  policy            = data.aws_iam_policy_document.sns.json

  tags = merge(var.tags, {
    Name = var.health_topic_name
  })
}

resource "aws_kms_key" "securityhub" {
  description             = "KMS Key for AWS Eventbridge securityhub"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "securityhub_alias" {
  target_key_id = aws_kms_key.securityhub.id
  name          = "alias/eventbridge_securityhub"
}

resource "aws_sns_topic" "securityhub" {
  name              = var.securityhub_topic_name
  display_name      = "SNS topic for AWS Eventbridge securityhub"
  kms_master_key_id = aws_kms_key.securityhub.arn
  policy            = data.aws_iam_policy_document.sns.json

  tags = merge(var.tags, {
    Name = var.securityhub_topic_name
  })
}

resource "aws_kms_key" "config" {
  description             = "KMS Key for AWS Eventbridge Config"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "config_alias" {
  target_key_id = aws_kms_key.config.id
  name          = "alias/eventbridge_config"
}

resource "aws_sns_topic" "config" {
  name              = var.config_topic_name
  display_name      = "SNS topic for AWS Eventbridge Config"
  kms_master_key_id = aws_kms_key.config.arn
  policy            = data.aws_iam_policy_document.config_sns.json

  tags = merge(var.tags, {
    Name = var.config_topic_name
  })
}
