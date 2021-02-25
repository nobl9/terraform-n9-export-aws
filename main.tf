provider "aws" {
  region = "eu-central-1"
}


module "aws_nobl9" {
  source         = "./modules/aws/nobl9"
  s3_bucket_name = "pies-testowy-kolorowy"
  tags = {
    "owner" : "jw",
    "purpose" : "testing",
    "department" : "dev",
  }
}

output "arn" {
  value = module.aws_nobl9.s3_bucket_arn
}
