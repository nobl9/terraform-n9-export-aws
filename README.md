# Export from Nobl9 module

This repo contains a set of modules in the modules folder for deploying exporting data from the Nobl9 application to
object storage and further integration for them using Terraform.

## How to use this Module

[modules](./modules): This folder contains several standalone, reusable, production-grade modules that you can use to
deploy exporting data from Nobl9 to chosen cloud provdier's object store and set up further integration for it.

[root folder](./): The root folder is an example of how to use modules to export data from Nobl9 to S3 bucket.
The Terraform Registry requires the root of every repo to contain Terraform code, so we've put one of the examples there.
This example is great for learning and experimenting, but for production use, probably more desirable is to use the
underlying modules in the [modules folder](./modules) directly.

## Code included in this Module

### AWS

- [nobl9](./modules/aws/nobl9): This module creates S3 bucket and IAM role which gives Nobl9 write access to it.
