output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Nobl9 to export data"
  value       = aws_s3_bucket.nobl9_exporter_bucket.bucket
}

output "iam_role_to_assume_by_nobl9" {
  description = "ARN of the IAM role for Nobl9 to assume to perform an export of data to the S3 bucket"
  value       = aws_iam_role.iam_role_to_assume_by_nobl9.arn
}
