variable "aws_region" {
  type        = string
  description = "AWS Region, such as 'eu-central-1'"
}

variable "aws_account_name" {
  type        = string
  description = "AWS Account Name"
}

variable "config_topic_name" {
  type        = string
  description = "SNS Topic name used for Config notifications"
  default     = "config-notifications"
}

variable "health_topic_name" {
  type        = string
  description = "SNS Topic name for Health notifications"
  default     = "eventbridge-health"
}

variable "backup_topic_name" {
  type        = string
  description = "SNS Topic name for Backup notifications"
  default     = "eventbridge-backup"
}

variable "securityhub_topic_name" {
  type        = string
  description = "SNS Topic name for Security Hub notifications"
  default     = "eventbridge-securityhub"
}

variable "slack_workspace_id" {
  type        = string
  description = "Slack Workspace ID for chatbot"
}

variable "slack_channel_id" {
  type        = string
  description = "Slack Channel ID for chatbot"
}

variable "chatbot_channels" {
  type = list(object({
    slack_channel_id   = string
    slack_workspace_id = string
    sns_topic_arns     = list(string)
    logging_level      = string
    configuration_name = string
    guardrail_policies = list(string)
  }))
  description = "The configs of the chatbot for Slack. To get the ID, open Slack, right click on the channel name in the left pane, then choose Copy Link. The channel ID is the 9-character string at the end of the URL. For example, ABCBBLZZZ. The ID of the Slack workspace authorized with AWS Chatbot. To get the workspace ID, you must perform the initial authorization flow with Slack in the AWS Chatbot console. Then you can copy and paste the workspace ID from the console. Logging levels include ERROR, INFO, or NONE."
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "securityhub_findings_filter" {
  type        = any
  description = "Additional filter for Security Hub findings (defaults to no filter)"
  default = {
    "findings" : {
      "Compliance" : {
        "Status" : ["FAILED", "WARNING"]
      },
      "Severity" : {
        "Label" : ["MEDIUM", "HIGH", "CRITICAL"]
      }
    }
  }
}

variable "inspector_findings_filter" {
  type        = any
  description = "Additional filter for AWS Inspector findings (defaults to no filter)"
  default = {
    "severity" : ["HIGH", "CRITICAL"],
    "status" : ["ACTIVE"]
  }
}

variable "budget_alert_threshold" {
  type        = string
  description = "Billing alert threshold in USD"
}

variable "budget_alert_subscribers" {
  type        = list(string)
  description = "List of email addresses with recipients for the billing alerts"
}

variable "disabled_securityhub_controls_list" {
  type = list(object({
    control_path    = string
    disabled_reason = string
  }))
  description = "List of disabled securityhub controls"
}
