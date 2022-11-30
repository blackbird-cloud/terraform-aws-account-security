resource "aws_budgets_budget" "budget" {
  name              = "BillingAlert"
  budget_type       = "COST"
  limit_amount      = var.budget_alert_threshold
  limit_unit        = "USD"
  time_period_start = "2022-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_alert_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_subscribers
  }
}
