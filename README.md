# Export from Nobl9 module

This repo contains a set of modules in the modules folder for deploying exporting data from the Nobl9 application to
object storage and further integration for them using Terraform.

## How to use this module

- The [modules](./modules) folder contains several standalone, reusable, production-grade modules that you can use to
deploy exporting data from Nobl9 to AWS S3 and set up a further integration with Snowflake.

- The [root folder](./) is an example of how to use modules to export data from Nobl9 to S3 bucket and set up
a further integration with Snowflake.<br>
The Terraform Registry requires the root of every repo to contain Terraform code.so we've put one of the examples there.
We've included an example in the registry. The example represents a typical scenario for learning and experimenting.
Use the underlying modules from the [modules folder](./modules) if you need fine-grained control.

## Code included in this module

### AWS

- The [nobl9](./modules/aws/nobl9) module creates an S3 bucket and IAM role, which gives the Nobl9 app `write` access
  to it.

- The [snowflake](./modules/aws/snowflake) module creates an IAM role which gives Snowflake `read` access to an existing
S3 bucket (for and instance provisioned with the above module) and configures notifications about file upload for [Snowpipe](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro.html).

## End-to-end example — set up export to S3 and connect with Snowflake

The root module uses [Nobl9](./modules/aws/nobl9) and [Snowflake](./modules/aws/snowflake) to provide end-to-end setup
for export from Nobl9 to S3 and integration with Snowflake. The following is a manual on how to use it.
When a more sophisticated configuration is required use modules [Nobl9](./modules/aws/nobl9) and
[Snowflake](./modules/aws/snowflake).

This module can be imported directly to (it is advised pinning a specific version by adding `?ref=<REF>`, e.g. `?ref=0.1.0`).

```hcl
module "aws_snowflake" {
  source = "git::git@github.com:nobl9/export-from-n9-terraform.git"
}
```

Parameters must be passed as described in the following step-by-step instructions.

### Export from N9 to S3

1. Obtain the AWS external ID for your organization in Nobl9 App UI or with the `sloctl` command-line tool.

2. Run the following command:

    ```bash
    sloctl get dataexport --aws-external-id
    ```

    Output

    ```bash
    <EXTERNAL_ID_FOR_ORGANIZATION>
    ```

3. Enter the variables for Terraform.<br>
  For example, create the file `input.auto.tfvars` in the root module with the following content:

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

    # Specify whether all objects should be deleted from the previously created S3 bucket when using terraform destroy.
    # This will allow destroying the non-empty S3 bucket without errors, when omitted default value: false is used.
    s3_bucket_force_destroy = <S3_BUCKET_FOR_N9_FORCE_DESTROY>
    ```

4. Initialize a new or existing Terraform working directory by running the following command:

    ```bash
    terraform init
    ```

    next

    ```bash
    terraform apply
    ```

5. Wait for the Terraform outputs.

    ```bash
    iam_role_to_assume_by_nobl9 = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/<NAME_OF_CREATED_ROLE_FOR_N9>"
    s3_bucket_name = "<S3_BUCKET_FOR_N9_DATA_NAME>"
    ```

6. Copy the above to the configuration of `DataExport` in the N9 App (YAML or UI). The data is exported
  every hour by the Nobl9 app to the S3 bucket.

    The following is an example Nobl9 YAML for `DataExport`, and can be applied with `sloctl` or configured with the UI.
    The field value for `roleArn` is obtained from Terraform output.

    ```yaml
    apiVersion: n9/v1alpha
    kind: DataExport
    metadata:
      name: data-export-s3
      project: default
    spec:
      exportType: S3
      spec:
        bucketName: "<S3_BUCKET_FOR_N9_DATA_NAME>"
        roleArn: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/<NAME_OF_CREATED_ROLE_FOR_N9>"
    ```

### Snowflake

Snowflake can automatically pull data from this bucket on every automatic upload done by N9 and make them available in
the database. Steps related to Snowflake have to be performed in its UI.

1. Create the database, table, and format for Nobl9 data in Snowflake.<br>
   Default names are used in the following setup (for example, `nobl9_slo` for database, etc.). Feel free to use
   different names.

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

2. Create the Snowflake integration with S3, enter the following with the desired values:

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

3. Obtain the following `<STORAGE_AWS_IAM_USER_ARN>` value and `<STORAGE_AWS_EXTERNAL_ID>` by running

    ```sql
    desc integration nobl9_s3;
    ```

4. Add the values from output of the above command to the Terraform variables as previously referenced (to file `input.auto.tfvars`)

    ```hcl
    snowflake_storage_aws_iam_user_arn = "<STORAGE_AWS_IAM_USER_ARN>"
    snowflake_storage_aws_external_id = "<STORAGE_AWS_EXTERNAL_ID>"
    # Previously referenced in Snowlake configuration, gives access to bucket.
    snowflake_iam_role_name = "<SNOWFLAKE_ROLE_NAME>" # Omit when default name snowflake-integration is used.
    ```

5. Apply the Terraform variables and wait.

    ```bash
    terraform apply
    ```

6. Run the following in Snowflake worksheet to set up the integration with S3

    ```sql
    create or replace stage s3_export_stage
      url = 's3://<BUCKET_NAME>'
      file_format = nobl9_csv_format
      storage_integration = nobl9_s3;
    ```

7. Start configuring Snowpipe

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

8. Add to Terraform variables as previous (e.g. to file `input.auto.tfvars`) ARN of SQS queue from Snowflake where
  notification about a new file in S3 will be sent.

    ```hcl
    snowflake_sqs_notification_arn = "<notification_channel>"
    ```

9. Run the `apply` command for the last time.

    ```bash
    terraform apply
    ```

From now on, the data from every file exported by Nobl9 to the dedicated S3 bucket should be available automatically in
the Snowflake database `nobl9_slo`.

- An example query to execute on data:

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

1. In Snowflake worksheet use the following command to delete the set up:

    ```sql
    drop database nobl9_slo;
    ```

    ```sql
    drop storage integration nobl9_s3;
    ```

2. Resources created with Terraform use the following to delete the set up:

    ```bash
    terraform destroy
    ```

    Objects in the S3 bucket prevent deletion unless `s3_bucket_force_destroy` variable is set to `true`.
    This will allow to destroy S3 bucket with its content.

3. The configuration of object DataExport should be deleted in Nobl9 too.
