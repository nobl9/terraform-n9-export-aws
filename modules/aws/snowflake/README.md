# S3 bucket for Nobl9 to export data

This folder contains a Terraform module that creates IAM role, which gives Snowflake read access to previously existed
S3 bucket and configure notifications for Snowpipe.

```hcl
module "aws_snowflake" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git//modules/aws/snowflake"
}
```

Note the following parameters:

`source`: Use this parameter to specify the URL of this module. The double slash (//) is intentional and required.
Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific
Git tag in this repo. That way, instead of using the latest version of this module from the main branch, which will
change every time you run Terraform, you're using a fixed version of the repo.

`s3_bucket_name`: Use this parameter to pass a name of the S3 bucket, which is designed to be a source of data for Snowflake.

`snowflake_storage_aws_iam_user_arn`: Use this parameter to

`snowflake_storage_aws_external_id`:

You can find the other parameters in [variables.tf](./variables.tf). Each of them has sensible default (or random value),
overwrite when you want to customize naming, tags, etc.

<!-- Note the **all outputs** from [outputs.tf](./outputs.tf) has to be passed to [Nobl9 application](http://app.nobl9.com/) during
creation of export integration to provide access. -->
