# S3 bucket for Nobl9 to export data

This folder contains a Terraform module that creates S3 bucket and IAM role which gives Nobl9 write access to it.

```hcl
module "aws_nobl9" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git//modules/aws/nobl9"
}
```

Note the following parameters:

`source`: Use this parameter to specify the URL of this module. The double slash (//) is intentional and required.
Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific
Git tag in this repo. That way, instead of using the latest version of this module from the master branch, which will
change every time you run Terraform, you're using a fixed version of the repo.

You can find the other parameters in [variables.tf](./variables.tf). Every of them has sensible default (or random value),
overwrite when you want to customize naming, tags, etc.

Note the **all outputs** from [outputs.tf](./outputs.tf) has to be passed to [Nobl9 application](http://app.nobl9.com/) during
creation of export integration to provide access.
