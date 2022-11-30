module "vpcflowlogs" {
  source             = "./bucket"
  purpose            = "vpc-flowlog"
  bucket_prefix      = "${var.aws_account_name}-vpc-flowlog"
  service_principals = ["delivery.logs.amazonaws.com"]
  object_actions     = []
  kms_actions = [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:DescribeKey",
  ]
  logging = {
    target_bucket = module.accesslogs.bucket.s3_bucket_id
    target_prefix = "vpcflowlogs"
  }
}
