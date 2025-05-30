data "aws_iam_policy_document" "access_to_s3" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]
    actions = [
      "s3:ListBucket",
    ]
  }
}

data "aws_iam_policy_document" "cross_account_assume_role_policy_for_snowflake" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.snowflake_storage_aws_iam_user_arn]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.snowflake_storage_aws_external_id]
    }
  }
}

resource "aws_iam_role" "iam_role_to_assume_by_snowflake" {
  name               = var.snowflake_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy_for_snowflake.json
  inline_policy {
    name   = "read-access-to-s3-bucket-${var.s3_bucket_name}"
    policy = data.aws_iam_policy_document.access_to_s3.json
  }
  tags = var.tags
}

resource "aws_s3_bucket_notification" "notification_about_new_file" {
  count = var.snowflake_sqs_notification_arn == "" ? 0 : 1

  bucket = var.s3_bucket_name
  queue {
    id        = "notification-to-snowflake-about-new-file"
    queue_arn = var.snowflake_sqs_notification_arn
    events    = ["s3:ObjectCreated:*"]
  }
}
