module "lblogs" {
  source                         = "./bucket"
  purpose                        = "lb-logs"
  acl                            = "log-delivery-write"
  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true
  bucket_prefix                  = "${var.aws_account_name}-lb-logs"
  logging = {
    target_bucket = module.accesslogs.bucket.s3_bucket_id
    target_prefix = "lb_logs"
  }
  encrypt_with_aws_managed_keys = true
}
