module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.13.3"

  create_bus = false

  rules = {
    health-events = {
      description = "AWS Health Events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.health"],
          "detail-type" : ["AWS Health Event"]
        }
      )
    }
    securityhub-events = {
      description = "AWS securityhub Events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.securityhub"],
          "detail-type" : ["Security Hub Findings - Imported"]
          "detail" : var.securityhub_findings_filter
        }
      )
    }
    inspector-events = {
      description = "AWS Inspector Findings Events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.inspector2"],
          "detail-type" : ["Inspector2 Finding"]
          "detail" : var.inspector_findings_filter
        }
      )
    }
    guardduty-events = {
      description = "AWS Inspector Findings Events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.guardduty"],
          "detail-type" : ["GuardDuty Finding"]
        }
      )
    }
    backup-job-fails-events = {
      description = "AWS Backup Job failed"
      event_pattern = jsonencode(
        {
          "source" : ["aws.backup"],
          "detail-type" : ["Backup Job State Change"],
          "detail" : {
            "state" : ["FAILED"]
          }
        }
      )
    }
    backup-copy-fails-events = {
      description = "AWS Backup Copy failed"
      event_pattern = jsonencode(
        {
          "source" : ["aws.backup"],
          "detail-type" : ["Copy Job State Change"],
          "detail" : {
            "state" : ["FAILED"]
          }
        }
      )
    }
    backup-restore-events = {
      description = "AWS Backup Restore started"
      event_pattern = jsonencode(
        {
          "source" : ["aws.backup"],
          "detail-type" : ["Restore Job State Change"],
          "detail" : {
            "state" : ["CREATED"]
          }
        }
      )
    }
  }
  targets = {
    health-events = [
      {
        name = "HealthEventsToSlack"
        arn  = aws_sns_topic.health.arn
      }
    ]
    securityhub-events = [
      {
        name = "securityhubEventsToSlack"
        arn  = aws_sns_topic.securityhub.arn
      }
    ]
    inspector-events = [
      {
        name = "inspectorEventsToSlack"
        arn  = aws_sns_topic.securityhub.arn
      }
    ]
    guardduty-events = [
      {
        name = "guarddutyEventsToSlack"
        arn  = aws_sns_topic.securityhub.arn
      }
    ]
    backup-job-fails-events = [
      {
        name = "BackupJobEventsToSlack"
        arn  = aws_sns_topic.backup.arn
      }
    ]
    backup-restore-events = [
      {
        name = "BackupRestoreEventsToSlack"
        arn  = aws_sns_topic.backup.arn
      }
    ]
    backup-copy-fails-events = [
      {
        name = "BackupCopyEventsToSlack"
        arn  = aws_sns_topic.backup.arn
      }
    ]
  }
}
