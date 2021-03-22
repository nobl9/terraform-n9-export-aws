# Export from Nobl9 module

This repo contains a set of modules in the modules folder for deploying exporting data from the Nobl9 application to
object storage and further integration for them using Terraform.

## How to use this module

[modules](./modules): This folder contains several standalone, reusable, production-grade modules that you can use to
deploy exporting data from Nobl9 to chosen cloud provider's object store and set up further integration for it.

[root folder](./): The root folder is an example of how to use modules to export data from Nobl9 to S3 bucket.
The Terraform Registry requires the root of every repo to contain Terraform code, so we've put one of the examples there.
This example is great for learning and experimenting, but for production use, probably more desirable is to use the
underlying modules from the [modules folder](./modules) directly.

## Code included in this module

### AWS

- [nobl9](./modules/aws/nobl9): This module creates S3 bucket and IAM role which gives Nobl9 write access to it.

- [snowflake](./modules/aws/snowflake): This module creates gives Snowflake access to an existing S3 bucket and configure
    notifications for [Snowpipe](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro.html).

## End to end example - set up export to S3 and connect with Snowflake

Root module uses [nobl9](./modules/aws/nobl9) and [snowflake](./modules/aws/snowflake) to provvide end to end set up
for export from Nobl9 to S3 and integration of it with Snowflake. Can be a gereat starting point and should be enough
in most cases. When more sophisticated configuration is required use modules [nobl9](./modules/aws/nobl9) and
[snowflake](./modules/aws/snowflake) directly.

### Export from N9 to S3

Check AWS external id for your organization in N9App UI or `sloctl`

```bash
sloctl get dataexport --aws-external-id
```

Output

```bash
<EXTERNAL_ID_FOR_ORGANIZATION>
```

Fill variables for Terraform, for instance create file `input.auto.tfvars`
with following content:

```hcl
aws_region = "<AWS_REGION_WHERE_TO_DEPLOY_RESOURCES>
external_id_provided_by_nobl9 = "<EXTERNAL_ID_FOR_ORGANIZATION>"
s3_bucket_name = "<S3_BUCKET_FOR_N9_DATA_NAME>" # Can be omitted random name will be generated.

# Optionally tags to add for every created resource.
tags = {
    "key: "value"
}

# Other available variables.
iam_role_to_assume_by_nobl9_name = "<NAME_OF_CREATED_ROLE_FOR_N9>" # Default is nobl9-exporter.
```

Let's apply it and wait

```bash
terraform apply
```

wait for terraform outputs

```bash
iam_role_to_assume_by_nobl9 = "arn:aws:iam::XXXXXXXXXXXX:role/nobl9-exporter"
s3_bucket_name = "<S3_BUCKET_FOR_N9_DATA_NAME>"
```

copy above to the configuration of `DataExport` in N9 App (YAML or UI). Every hour content will
be exported.

### Snowflake

Snowflake can automatically pull data from this bucket on every automatic upload done by N9 and make them available in
the database. Steps related to Snowflake have to be performed in its UI.

Create the database, table, and format for Nobl9 data.

```sql
create database nobl9_slo;
```

```sql
create or replace table nobl9_data(
  timestamp datetime,
  organization string,
  measurement string,
  objective string,
  value double,
  project string,
  threshold double,
  good_count number,
  total_count number,
  objective_description string,
  error_budget_method string,
  metric_source_name string,
  threshold_name string,
  budget_target double,
  threshold_tag string,
  service string,
  service_display_name string,
  service_description string
);
```

```sql
create or replace file format nobl9_csv_format
  type = csv
  field_delimiter = ','
  skip_header = 1
  null_if = ('NULL', 'null')
  empty_field_as_null = true
  compression = gzip;
```

Create Snowflake integration with S3, fill below with desired values:

- `<AWS_ACCOUNT_ID>` - id of account where is S3 bucket was created
- `<SNOWFLAKE_ROLE_NAME>` - the name of the IAM role to be assumed by Snowflake, when not specified by a Terraform
  configuration is `snowflake-integration` (as default)
- `<BUCKET_NAME>` - the name of previously created S3 bucket (from Terreform output)

```sql
create or replace storage integration nobl9_s3
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/<SNOWFLAKE_ROLE_NAME>'
  storage_allowed_locations = ('s3://<BUCKET_NAME>');
```

To obtain

- `<STORAGE_AWS_IAM_USER_ARN>`
- `<STORAGE_AWS_EXTERNAL_ID>`

from Snowflake execute

```sql
desc integration nobl9_s3;
```

and results add to Terraform variables as previous to file `input.auto.tfvars`

```hcl
snowflake_storage_aws_iam_user_arn = <STORAGE_AWS_IAM_USER_ARN>
snowflake_storage_aws_external_id = <STORAGE_AWS_EXTERNAL_ID>
snowflake_iam_role_name = <SNOWFLAKE_ROLE_NAME> # Omit when default name is used.
```

next apply it and wait

```bash
terraform apply
```

After successful finish, execute below in Snowflake console

```sql
create or replace stage s3_export_stage
  url = 's3://<BUCKET_NAME>'
  file_format = nobl9_csv_format
  storage_integration = nobl9_s3;
```

next start configuring Snowpipe

```sql
create pipe nobl9_data_pipe auto_ingest=true as
  copy into nobl9_data
    from @s3_export_stage;
```

The above command ends successfully only if the previous configuration of access by Snowflake to S3 was done correctly.

```sql
desc pipe nobl9_data_pipe;
```

Add to terraform file ARN of SQS queue from Snowflake where notification about a new file in S3 will be sent.

```hcl
snowflake_sqs_notification_arn = <notification_channel>
```

Execute apply for the last time

```bash
terraform apply
```

From now data from every file exported by N9 to configured S3 bucket should be available automatically in Snowflake
database `nobl9_slo`.

Example query to execute on data

```sql
select timestamp, good_count, total_count from nobl9_data where
  objective = 'streaming-latency-slo' // SLO name
  and measurement = 'counts';
```

### Deletion of the whole set up

In Snowflake console

```sql
drop database nobl9_slo;
drop storage integration nobl9_s3;
```

for resources created with Terraform

```bash
terraform destroy
```

The configuration of DataExport should be deleted in N9App too.
