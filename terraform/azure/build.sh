#!/bin/bash

# Load .env from repository root
set -a
source ../../.env
set +a

# Run Terraform for snowflake.tf
terraform init
terraform plan
terraform apply