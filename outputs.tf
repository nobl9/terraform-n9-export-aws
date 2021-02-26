output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Nobl9 to export data"
  value       = module.aws_nobl9.s3_bucket_name
}

output "role_to_assume_by_nobl9" {
  description = "ARN of the role for Nobl9 to assume to perfrom export of data to the S3 bucket"
  value       = module.aws_nobl9.role_to_assume_by_nobl9
}

output "external_id_for_nobl9" {
  description = "External ID for Nobl9 to required to assume the role to perfrom export of data to the S3 bucket"
  value       = module.aws_nobl9.external_id_for_nobl9
}
