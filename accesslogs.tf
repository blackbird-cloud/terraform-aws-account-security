module "accesslogs" {
  source             = "./bucket"
  purpose            = "access-logs"
  bucket_prefix      = "${var.aws_account_name}-access-logs"
  service_principals = ["logging.s3.amazonaws.com"]
}
