variable "s3_bucket_name" {
  description = "Name of S3 bucket to create for Nobl9 to export data"
  type        = string
}

variable "nobl9_aws_account_id" {
  description = "AWS account ID of Nobl9"
  type        = string
  default     = 922330643383
}
