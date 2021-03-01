variable "s3_bucket_name" {
  description = "Name of S3 bucket to create for Nobl9 to export data (if omitted random name will be assigned)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "external_id_for_role_to_assume_by_nobl9" {
  description = "External ID which Nobl9 needs to know to assume the IAM role (if omitted, the random value will be assigned)"
  type        = string
  default     = ""
}

variable "iam_role_to_assume_by_nobl9_name" {
  description = "Name of the role which is designed to be assumed by Nobl9 to get access to the previously created S3 bucket"
  type        = string
  default     = "nobl9-exporter"
}

variable "nobl9_aws_account_id" {
  description = "Nobl9 AWS account ID which be will be granted access to the S3 bucket"
  type        = string
  default     = 703270577975
}
