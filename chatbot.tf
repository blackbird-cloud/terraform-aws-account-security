locals {
  chatbot_channels = var.chatbot_channels != null ? var.chatbot_channels : [
    {
      slack_channel_id   = var.slack_channel_id
      slack_workspace_id = var.slack_workspace_id
      sns_topic_arns = [
        aws_sns_topic.backup.arn,
        aws_sns_topic.config.arn,
        aws_sns_topic.health.arn,
        aws_sns_topic.securityhub.arn
      ]
      logging_level      = "INFO"
      configuration_name = "AllAccountMessages"
      guardrail_policies = [
        "arn:aws:iam::aws:policy/ReadOnly"
      ]
    }
  ]
}

module "chatbot_config" {
  source  = "waveaccounting/chatbot-slack-configuration/aws"
  version = "1.1.0"

  for_each = {
    for channel in local.chatbot_channels : channel.configuration_name => channel
  }

  iam_role_arn = module.iam_chatbot_role.iam_role_arn

  configuration_name = each.value.configuration_name
  logging_level      = each.value.logging_level
  slack_channel_id   = each.value.slack_channel_id
  slack_workspace_id = each.value.slack_workspace_id
  sns_topic_arns     = each.value.sns_topic_arns
  guardrail_policies = each.value.guardrail_policies
}
