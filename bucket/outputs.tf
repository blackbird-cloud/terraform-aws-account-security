output "bucket" {
  value       = module.bucket
  description = "S3 bucket"
}

output "kms" {
  value       = var.encrypt_with_aws_managed_keys ? null : aws_kms_key.kms[0]
  description = "KMS key"
}
