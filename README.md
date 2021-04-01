# Export from Nobl9 module

This repo contains a set of modules in the modules folder for deploying exporting data from the Nobl9 application to
object storage and further integration for them using Terraform.

## How to use this module

[modules](./modules): This folder contains several standalone, reusable, production-grade modules that you can use to
deploy exporting data from Nobl9 to AWS S3 and set up further integration with Snowflake for it.

[root folder](./): The root folder is an example of how to use modules to export data from Nobl9 to S3 bucket and set up
further integration with Snowflake. The Terraform Registry requires the root of every repo to contain Terraform code,
so we've put one of the examples there. This example is great for the typical scenario, learning and experimenting.
In case of need for fine-grained control use the underlying modules from the [modules folder](./modules) directly.

## Code included in this module

### AWS

- [nobl9](./modules/aws/nobl9): This module creates S3 bucket and IAM role, which gives Nobl9 app write access to it.

- [snowflake](./modules/aws/snowflake): This module creates IAM role which gives Snowflake read access to an existing S3
  bucket (for instance provisioned with the above module) and configures notifications about file upload for [Snowpipe](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro.html).

## End to end example - set up export to S3 and connect with Snowflake

Root module uses [nobl9](./modules/aws/nobl9) and [snowflake](./modules/aws/snowflake) to provide end to end setup
for export from Nobl9 to S3 and integration of it with Snowflake. Below there is the manual on how to use it directly.
When more sophisticated configuration is required use modules [nobl9](./modules/aws/nobl9) and
[snowflake](./modules/aws/snowflake) directly.

This module can be imported directly too (it is advised pinning a specific version by adding `?ref=<REF>`, e.g. `?ref=0.1.0`).

```hcl
module "aws_snowflake" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git"
}
```

Parameters need to be passed as described in the below step by step instructions.

### Export from N9 to S3

Obtain AWS external ID for your organization in Nobl9 App UI or with command line tool - `sloctl`.

Execute

```bash
sloctl get dataexport --aws-external-id
```

Output

```bash
<EXTERNAL_ID_FOR_ORGANIZATION>
```

Fill variables for Terraform, for instance create file `input.auto.tfvars` in root module
with following content:

```hcl
aws_region = "<AWS_REGION_WHERE_TO_DEPLOY_RESOURCES>"  # Region where Terraform provsion S3 bucket.
external_id_provided_by_nobl9 = "<EXTERNAL_ID_FOR_ORGANIZATION>"  # Previously obtained from Nobl9 external id.
s3_bucket_name = "<S3_BUCKET_FOR_N9_DATA_NAME>" # Specify desired name for bucket, when omitted random name will be generated.

# Optionally tags to add for every created resource.
tags = {
    "key": "value"
}

# Other available variables.

# Specify the desired name for the IAM role, which gives Nobl9 access to the created bucket,
# when omitted default name: nobl9-exporter is used.
iam_role_to_assume_by_nobl9_name = "<NAME_OF_CREATED_ROLE_FOR_N9>"
```

Firstly initialize a new or existing Terraform working directory by executing

```bash
terraform init
```

next

```bash
terraform apply
```

wait for Terraform outputs.

```bash
iam_role_to_assume_by_nobl9 = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/<NAME_OF_CREATED_ROLE_FOR_N9>"
s3_bucket_name = "<S3_BUCKET_FOR_N9_DATA_NAME>"
```

Copy the above to the configuration of `DataExport` in N9 App (YAML or UI). Data will be exported
every hour by Nobl9 app to the S3 bucket.

Example Nobl9 YAML for `DataExport`, can be applied with `sloctl` or configured with UI. Value for
field `roleArn` can be obtained from Terraform output.

```yaml
apiVersion: n9/v1alpha
kind: DataExport
metadata:
  name: data-export-s3
  project: default
spec:
  s3BucketName: "<S3_BUCKET_FOR_N9_DATA_NAME>"
  roleArn: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/<NAME_OF_CREATED_ROLE_FOR_N9>"
  exportType: S3
```

### Snowflake

Snowflake can automatically pull data from this bucket on every automatic upload done by N9 and make them available in
the database. Steps related to Snowflake have to be performed in its UI.

Create the database, table, and format for Nobl9 data in Snowflake. Some default names (like `nobl9_slo` for database, etc.)
are used in the below setup. In case of need, feel free to use different names.

```sql
create database nobl9_slo;
```

```sql
create or replace table nobl9_data(
  timestamp datetime not null,
  organization string not null,
  project string not null,
  measurement string not null,
  value double not null,
  time_window_start datetime,
  time_window_end datetime,
  slo_name string not null,
  slo_description string,
  error_budgeting_method string not null,
  budget_target double not null,
  objective_name string,
  objective_value double,
  objective_operator string,
  service string not null,
  service_display_name string,
  service_description string,
  slo_time_window_type string not null,
  slo_time_window_duration_unit string not null,
  slo_time_window_duration_count int not null,
  slo_time_window_start_time timestamp_tz
);
```

```sql
create or replace file format nobl9_csv_format
  type = csv
  field_delimiter = ','
  skip_header = 1
  null_if = ('NULL', 'null')
  empty_field_as_null = true
  field_optionally_enclosed_by = '"'
  compression = gzip;
```

Create Snowflake integration with S3, fill below with desired values:

- `<AWS_ACCOUNT_ID>` - ID of AWS account where the S3 bucket for Nobl9 was created
- `<SNOWFLAKE_ROLE_NAME>` - name of the IAM role to create to be assumed by Snowflake, when omitted
  in Terraform configuration default name `snowflake-integration` has to be used
- `<BUCKET_NAME>` - the name of previously created S3 bucket (from Terraform output)

```sql
create or replace storage integration nobl9_s3
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/<SNOWFLAKE_ROLE_NAME>'
  storage_allowed_locations = ('s3://<BUCKET_NAME>');
```

For the next step obtain

- `<STORAGE_AWS_IAM_USER_ARN>`
- `<STORAGE_AWS_EXTERNAL_ID>`

from Snowflake by executing

```sql
desc integration nobl9_s3;
```

Values from output of the above command add to Terraform variables as previous (to file `input.auto.tfvars`)

```hcl
snowflake_storage_aws_iam_user_arn = "<STORAGE_AWS_IAM_USER_ARN>"
snowflake_storage_aws_external_id = "<STORAGE_AWS_EXTERNAL_ID>"
# Previously referenced in Snowlake configuration, gives access to bucket.
snowflake_iam_role_name = "<SNOWFLAKE_ROLE_NAME>" # Omit when default name snowflake-integration is used.
```

next, apply it and wait

```bash
terraform apply
```

After successful finish, execute below in Snowflake worksheet to set up integration with S3

```sql
create or replace stage s3_export_stage
  url = 's3://<BUCKET_NAME>'
  file_format = nobl9_csv_format
  storage_integration = nobl9_s3;
```

next, start configuring Snowpipe

```sql
create pipe nobl9_data_pipe auto_ingest=true as
  copy into nobl9_data
    from @s3_export_stage;
```

The above command will end successfully only when the configuration of access by Snowflake (previous steps) to S3 was
done correctly.

```sql
desc pipe nobl9_data_pipe;
```

Add to Terraform variables as previous (e.g. to file `input.auto.tfvars`) ARN of SQS queue from Snowflake where
notification about a new file in S3 will be sent.

```hcl
snowflake_sqs_notification_arn = "<notification_channel>"
```

Execute apply, for the last time

```bash
terraform apply
```

From now on, data from every file exported by Nobl9 to the dedicated S3 bucket should be available automatically in Snowflake
database `nobl9_slo`.

An example query to execute on data

```sql
select distinct
  service_display_name,
  service,
  project,
  slo_name,
  objective_name,
  objective_value,
  budget_target * 100 as target
from nobl9_data
order by service, slo_name;
```

### Deletion of the whole set up

In Snowflake worksheet

```sql
drop database nobl9_slo;
```

```sql
drop storage integration nobl9_s3;
```

for resources created with Terraform

```bash
terraform destroy
```

The configuration of object DataExport should be deleted in Nobl9 too.
