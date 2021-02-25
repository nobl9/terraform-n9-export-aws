output "s3_bucket_arn" {
  description = "ARN of S3 bucket created for Nobl9 to export data"
  value       = aws_s3_bucket.nobl9_exporer_bucket.arn
}
