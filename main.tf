provider "aws" {
  region = "us-east-1"
}

module "aws_nobl9" {
  source = "./modules/aws/nobl9"
  # s3_bucket_name               = "kolorowy-pies-testowy"
  role_to_assume_by_nobl9_name = "n9-access"
  tags = {
    "owner" : "jw",
    "purpose" : "testing",
    "department" : "dev",
  }
  external_id_for_role_to_assume_by_nobl9 = "koty"
}

output "bucket_name" {
  value = module.aws_nobl9.s3_bucket_name
}
output "role_arn" {
  value = module.aws_nobl9.role_to_assume_by_nobl9
}

output "external_id" {
  value = module.aws_nobl9.external_id_for_nobl9
}
