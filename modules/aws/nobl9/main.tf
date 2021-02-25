data "aws_iam_policy_document" "cross_account_assume_role_policy_for_nobl9" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.nobl9_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "access_to_s3" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
  }
}

resource "aws_iam_role" "cross_account_assume_role" {
  name               = "n9-exporter-role"
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy_for_nobl9.json
  inline_policy {
    name   = "write-access-to-s3"
    policy = data.aws_iam_policy_document.access_to_s3.json
  }
  tags = var.tags
}


resource "aws_s3_bucket" "nobl9_exporer_bucket" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}
