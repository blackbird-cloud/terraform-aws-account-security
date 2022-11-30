variable "purpose" {
  description = "purpose"
  type        = string
}

variable "service_principals" {
  description = "service_principals"
  type        = list(string)
  default     = []
}

variable "iam_principals" {
  description = "iam_principals"
  type        = list(string)
  default     = []
}

variable "object_actions" {
  description = "object_actions"
  type        = list(string)
  default     = ["s3:PutObject"]
}

variable "bucket_actions" {
  description = "bucket_actions"
  type        = list(string)
  default     = []
}

variable "kms_actions" {
  description = "kms_actions"
  type        = list(string)
  default     = ["kms:GenerateDataKey*"]
}

variable "acl" {
  description = "acl"
  type        = string
  default     = "private"
}

variable "versioning" {
  description = "versioning"
  type        = bool
  default     = true
}

variable "logging" {
  type        = map(string)
  description = "target_bucket and target_prefix"
  default     = {}
}

variable "bucket_prefix" {
  description = "bucket_prefix"
  type        = string
}

variable "attach_elb_log_delivery_policy" {
  description = "attach_elb_log_delivery_policy"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "attach_lb_log_delivery_policy"
  type        = bool
  default     = false
}

variable "encrypt_with_aws_managed_keys" {
  description = "encrypt_with_aws_managed_keys"
  type        = bool
  default     = false
}
