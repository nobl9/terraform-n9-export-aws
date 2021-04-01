# S3 bucket for Nobl9 to export data

This folder contains a Terraform module that creates IAM role, which gives Snowflake read access to previously existed
S3 bucket and configure notifications on file upload for Snowpipe. Some steps are required to be configured in AWS
before Snowflake and some in Snowflake before AWS. Hence adding parameters and executing `terraform apply` multiple time
is required - steps and usage are the same [as described for root module](../../../README.md###Snowflake).

```hcl
module "aws_snowflake" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git//modules/aws/snowflake"
}
```

For the above, it is advised pinning to a specific version by adding `?ref=<REF>`, e.g. `?ref=0.1.0`.

Note the following parameters:

`source`: Use this parameter to specify the URL of this module. The double slash (//) is intentional and required.
Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific
Git tag in this repo. That way, instead of using the latest version of this module from the main branch, which will
change every time you run Terraform, you're using a fixed version of the repo.

`s3_bucket_name`: Use this parameter to pass a name of the S3 bucket, which is designed to be a source of data for Snowflake.

`snowflake_storage_aws_iam_user_arn`: Snowflake's AWS user, has to be obtained from Snowflake

`snowflake_storage_aws_external_id`:  AWS external ID from Snowflake, has to be obtained from Snowflake

`snowflake_sqs_notification_arn`: ARN of SQS queue where notifications about new files are sent

You can find the other parameters in [variables.tf](./variables.tf). Each of them has sensible default (or random value),
overwrite when you want to customize naming, tags, etc.
