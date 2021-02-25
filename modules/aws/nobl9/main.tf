resource "aws_s3_bucket" "nobl9_exporter_bucket" {
  bucket = var.s3_bucket_name
  tags   = var.tags
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

resource "random_uuid" "default_external_id" {
}

locals {
  external_id = var.external_id_for_role_to_assume_by_nobl9 != "" ? var.external_id_for_role_to_assume_by_nobl9 : random_uuid.default_external_id.result
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
      values   = [local.external_id]
    }
  }
}

resource "aws_iam_role" "role_to_assume_by_nobl9" {
  name               = var.role_to_assume_by_nobl9_name
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy_for_nobl9.json
  inline_policy {
    name   = "write-access-to-s3"
    policy = data.aws_iam_policy_document.access_to_s3.json
  }
  tags = var.tags
}
