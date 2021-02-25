variable "s3_bucket_name" {
  description = "Name of S3 bucket to create for Nobl9 to export data"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "nobl9_aws_account_id" {
  description = "AWS account ID of Nobl9 to grant access to S3 bucket"
  type        = string
  default     = 922330643383
}
