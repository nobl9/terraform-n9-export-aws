provider "aws" {
  region = "us-east-1"
}

module "aws_nobl9" {
  source                                  = "./modules/aws/nobl9"
  s3_bucket_name                          = var.s3_bucket_name
  tags                                    = var.tags
  external_id_for_role_to_assume_by_nobl9 = var.external_id_for_role_to_assume_by_nobl9
  role_to_assume_by_nobl9_name            = var.role_to_assume_by_nobl9_name
}
