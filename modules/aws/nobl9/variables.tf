variable "s3_bucket_name" {
  description = "Name of S3 bucket to create for Nobl9 to export data (if ommited random name will be assigned)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

variable "external_id_for_role_to_assume_by_nobl9" {
  description = "External ID which Nobl9 needs to know to assume role (if ommited random value will be assigned)"
  type        = string
  default     = ""
}

variable "role_to_assume_by_nobl9_name" {
  description = "Name of the role which is designed to be assumed by Nobl9 to get access to the previously created S3 bucket"
  type        = string
}

variable "nobl9_aws_account_id" {
  description = "AWS account ID of Nobl9 to grant access to the S3 bucket"
  type        = string
  default     = 922330643383
}
