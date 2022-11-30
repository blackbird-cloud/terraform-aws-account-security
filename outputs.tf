output "health_sns_topic_arn" {
  value       = aws_sns_topic.health.arn
  description = "SNS Health topic ARN"
}

output "securityhub_sns_topic_arn" {
  value       = aws_sns_topic.securityhub.arn
  description = "SNS Security Hub topic ARN"
}

output "backup_sns_topic_arn" {
  value       = aws_sns_topic.backup.arn
  description = "SNS Backup topic ARN"
}

output "vpcflowlogs" {
  value       = module.vpcflowlogs
  description = "VPC flow logs"
}

output "lblogs" {
  value       = module.lblogs
  description = "LB flow logs"
}

output "accesslogs" {
  value       = module.accesslogs
  description = "Access logs"
}
