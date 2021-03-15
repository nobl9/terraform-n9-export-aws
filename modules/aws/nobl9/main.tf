resource "aws_s3_bucket" "nobl9_exporter_bucket" {
  bucket = var.s3_bucket_name
  tags   = var.tags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_all_public_access" {
  bucket                  = aws_s3_bucket.nobl9_exporter_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "access_to_s3" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.nobl9_exporter_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.nobl9_exporter_bucket.bucket}/*",
    ]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_iam_policy_document" "cross_account_assume_role_policy_for_nobl9" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.nobl9_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id_provided_by_nobl9]
    }
  }
}

resource "aws_iam_role" "iam_role_to_assume_by_nobl9" {
  name               = var.iam_role_to_assume_by_nobl9_name
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy_for_nobl9.json
  inline_policy {
    name   = "write-access-to-s3-bucket-${aws_s3_bucket.nobl9_exporter_bucket.bucket}"
    policy = data.aws_iam_policy_document.access_to_s3.json
  }
  tags = var.tags
}
