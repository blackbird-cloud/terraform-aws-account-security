module "all_cis_alarms" {
  source         = "terraform-aws-modules/cloudwatch/aws//modules/cis-alarms"
  version        = "3.2.0"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  alarm_actions  = [aws_sns_topic.securityhub.arn]
}
