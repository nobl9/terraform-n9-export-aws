# S3 bucket for Nobl9 to export data

This folder contains a Terraform module that creates S3 bucket and IAM role which gives Nobl9 write access to it.

```hcl
module "aws_nobl9" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git//modules/aws/nobl9"

}
```
