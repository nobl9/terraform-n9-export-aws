output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Nobl9 to export data"
  value       = aws_s3_bucket.nobl9_exporter_bucket.bucket
}

output "role_to_assume_by_nobl9" {
  description = "ARN of the role for Nobl9 to assume to perfrom export of data to the S3 bucket"
  value       = aws_iam_role.role_to_assume_by_nobl9.arn
}

output "external_id_for_nobl9" {
  description = "External ID for Nobl9 to required to assume the role to perfrom export of data to the S3 bucket"
  value       = local.external_id
}
