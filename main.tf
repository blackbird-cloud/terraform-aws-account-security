resource "aws_securityhub_account" "account" {}

# https://docs.aws.amazon.com/cli/latest/reference/securityhub/describe-standards.html
resource "aws_securityhub_standards_subscription" "cis" {
  depends_on    = [aws_securityhub_account.account]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
}

resource "aws_securityhub_standards_subscription" "best_practices" {
  depends_on    = [aws_securityhub_account.account]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_control" "disabled_control" {
  for_each = { for control_list in var.disabled_securityhub_controls_list : control_list.control_path => control_list }

  standards_control_arn = "arn:aws:securityhub:${var.aws_region}:${data.aws_caller_identity.current.account_id}:control/${each.value.control_path}"
  control_status        = "DISABLED"
  disabled_reason       = each.value.disabled_reason

  depends_on = [aws_securityhub_standards_subscription.best_practices, aws_securityhub_standards_subscription.cis]
}
