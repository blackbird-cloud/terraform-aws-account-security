resource "aws_iam_role" "config" {
  name = "config-role-${var.aws_account_name}"

  tags = merge(var.tags, {
    Name = "config-role-${var.aws_account_name}"
  })

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "config_s3" {
  name        = "Config-S3"
  description = "Config S3 policy"

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource":[
        "${module.config.bucket.s3_bucket_arn}/config/*"
      ],
      "Condition":{
        "StringLike":{
          "s3:x-amz-acl":"bucket-owner-full-control"
        }
      }
    },
    {
      "Effect":"Allow",
      "Action":[
        "s3:GetBucketAcl"
      ],
      "Resource":"${module.config.bucket.s3_bucket_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "config_s3" {
  role       = aws_iam_role.config.name
  policy_arn = aws_iam_policy.config_s3.arn
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

module "iam_chatbot_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  create_role           = true
  trusted_role_services = ["chatbot.amazonaws.com"]

  role_name = "AWSChatbot"
  role_path = "/modules/chatbot/"

  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
}
