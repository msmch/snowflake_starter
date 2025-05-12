variable "ORG_NAME" {
  type = string
  description = "Snowflake organization name."
}

variable "ACCOUNT" {
  type = string
  description = "Snowflake account identifier."
}

variable "DEPLOYMENT_USER" {
  type = string
  description = "Snowflake user dedicated for Terraform"
}

variable "DEPLOYMENT_ROLE" {
  type = string
  description = "Snowflake role granted to DEPLOYMENT_USER allowing to create warehouses, schemas, databases."
}

variable "PRIVATE_KEY_PATH" {
  type = string
  description = "Filepath to a file storing Terrafrom user private key."
}