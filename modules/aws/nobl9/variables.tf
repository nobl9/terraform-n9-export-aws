variable "external_id_provided_by_nobl9" {
  description = "External ID provided by Nobl9 to assume the IAM role"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of S3 bucket to create for Nobl9 to export data (if omitted random name will be assigned)"
  type        = string
  default     = ""
}

variable "s3_bucket_force_destroy" {
  description = "Indicates whether all objects should be deleted from the S3 bucket (on terraform destroy) so that the bucket can be destroyed without errors"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "iam_role_to_assume_by_nobl9_name" {
  description = "Name of the role which is designed to be assumed by Nobl9 to get access to the previously created S3 bucket"
  type        = string
  default     = "nobl9-exporter"
}

variable "nobl9_aws_account_id" {
  description = "Nobl9 AWS account ID which will be granted access to the S3 bucket"
  type        = string
  default     = 703270577975
}
