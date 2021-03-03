terraform {
  required_version = ">= 0.14.7"
}

data "aws_region" "current" {
}

module "aws_nobl9" {
  source = "./modules/aws/nobl9"

  external_id_provided_by_nobl9    = var.external_id_provided_by_nobl9
  s3_bucket_name                   = var.s3_bucket_name
  tags                             = var.tags
  iam_role_to_assume_by_nobl9_name = var.iam_role_to_assume_by_nobl9_name
  nobl9_aws_account_id             = var.nobl9_aws_account_id
}

module "aws_snowflake" {
  source = "./modules/aws/snowflake"

  s3_bucket_name                       = module.aws_nobl9.s3_bucket_name
  tags                                 = var.tags
  snowflake_STORAGE_AWS_IAM_USER_ARN   = "arn:aws:iam::899732416758:user/f1wx-s-euss6305"
  snowflake_STORAGE_AWS_EXTERNAL_ID    = "SM22383_SFCRole=2_uKPfR4u/ewCVVXEE6194hlrURRc="
  iam_role_to_assume_by_snowflake_name = "snowflake-access"
}
