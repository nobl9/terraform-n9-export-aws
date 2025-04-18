terraform {
  required_version = ">= 0.14.7"
}

provider "aws" {
  region = var.aws_region
}

module "aws_nobl9" {
  source = "./modules/aws/nobl9"

  s3_bucket_name                   = var.s3_bucket_name
  s3_bucket_force_destroy          = var.s3_bucket_force_destroy
  tags                             = var.tags
  iam_role_to_assume_by_nobl9_name = var.iam_role_to_assume_by_nobl9_name
  external_id_provided_by_nobl9    = var.external_id_provided_by_nobl9
  nobl9_aws_account_id             = var.nobl9_aws_account_id
}

module "aws_snowflake" {
  source     = "./modules/aws/snowflake"
  count      = var.snowflake_storage_aws_iam_user_arn == "" || var.snowflake_storage_aws_external_id == "" ? 0 : 1
  depends_on = [module.aws_nobl9]

  s3_bucket_name                     = module.aws_nobl9.s3_bucket_name
  tags                               = var.tags
  snowflake_storage_aws_iam_user_arn = var.snowflake_storage_aws_iam_user_arn
  snowflake_storage_aws_external_id  = var.snowflake_storage_aws_external_id
  snowflake_sqs_notification_arn     = var.snowflake_sqs_notification_arn
  snowflake_iam_role_name            = var.snowflake_iam_role_name
}
