variable "s3_bucket_name" {
  description = "Name of S3 bucket to give permissions for Snowflake to access"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "snowflake_STORAGE_AWS_IAM_USER_ARN" {
  description = "AWS user ARN which Snowflake returns for configured integration"
  type        = string
  default     = ""
}

variable "snowflake_STORAGE_AWS_EXTERNAL_ID" {
  description = "External ID which Snowflake returns for configured integration"
  type        = string
}

variable "iam_role_to_assume_by_snowflake_name" {
  description = "Name of the role which is designed to be assumed by Snowflake to get access to the previously created S3 bucket"
  type        = string
  default     = "snowflake-integration"
}
