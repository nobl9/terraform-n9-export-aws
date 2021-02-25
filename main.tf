provider "aws" {
  region = "eu-central-1"
}


module "aws_nobl9" {
  source         = "./modules/aws/nobl9"
  s3_bucket_name = "pies"
}

output "w" {
  value = module.aws_nobl9.s3_bucket_arn
}
