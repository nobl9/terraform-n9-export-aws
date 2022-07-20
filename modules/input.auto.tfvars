# Region where Terraform provisions the S3 bucket
aws_region = "eu-west-1"

# Previously obtained from Nobl9 external id
external_id_provided_by_nobl9 = "n9-integration-outsystems"

# Specify desired name for bucket. If omitted, random name will be generated
# Optionally, tags to add for every created resource.
s3_bucket_name = "outsystems-nobl9-s3-data-bucket"

tags = {
"key": "outsystems-nobl9-s3-data-bucket"
}