
variable "AZURE_SUBSCRIPTION_ID" {
  type        = string
  description = "Azure subscription id."
}

variable "SNOWFLAKE_STARTER_RG" {
  type        = string
  description = "Azure resource group name."
}

variable "SNOWFLAKE_STARTER_STORAGE_ACC" {
  type        = string
  description = "Azure storage account name."
}

variable "SNOWFLAKE_STARTER_STORAGE_ACC_CONT" {
  type        = string
  description = "Azure storage account container name."
}


variable "SNOWFLAKE_STARTER_LOCAL_FILES_PATH" {
  type        = string
  description = "Local path to the files folder."
}

