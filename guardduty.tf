resource "aws_guardduty_detector" "detector" {
  finding_publishing_frequency = "SIX_HOURS"
  enable                       = true
}
