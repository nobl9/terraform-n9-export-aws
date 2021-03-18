variable "s3_bucket_name" {
  description = "Name of S3 bucket to give permissions for Snowflake to access"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "snowflake_storage_aws_iam_user_arn" {
  description = "AWS user ARN which Snowflake returns for configured integration"
  type        = string
  default     = ""
}

variable "snowflake_storage_aws_external_id" {
  description = "External ID which Snowflake returns for configured integration"
  type        = string
  default     = ""
}

variable "snowflake_iam_role_name" {
  description = "Name of the role which is designed to be assumed by Snowflake to get access to the previously created S3 bucket"
  type        = string
  default     = "snowflake-integration"
}

variable "snowflake_sqs_notification_arn" {
  description = "ARN of SQS provided by Snowflake to send notifications about new files in the S3 bucket (if omitted notification is not set)"
  type        = string
  default     = ""
}
