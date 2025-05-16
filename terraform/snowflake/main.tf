terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
      version = ">= 2.0.0"
    }
  }
}

provider "snowflake" {
  organization_name = var.ORG_NAME
  account_name = var.ACCOUNT
  user = var.DEPLOYMENT_USER
  role = var.DEPLOYMENT_ROLE
  authenticator = "SNOWFLAKE_JWT"
  private_key = file(var.PRIVATE_KEY_PATH)
}

# Warehouses
resource "snowflake_warehouse" "xs_backend" {
  name = "XS_BACKEND"
  warehouse_size = "XSMALL"
  auto_suspend = 60
  auto_resume = true
}

resource "snowflake_warehouse" "xs_analytics" {
  name = "XS_ANALYTICS"
  warehouse_size = "XSMALL"
  auto_suspend = 60
  auto_resume = true
}

resource "snowflake_warehouse" "xs_dev" {
  name = "XS_DEV"
  warehouse_size = "XSMALL"
  auto_suspend = 60
  auto_resume = true
}


resource "snowflake_warehouse" "xs_snowpark" {
  name = "XS_SNOWPARK"
  warehouse_size = "XSMALL"
  auto_suspend = 60
  auto_resume = true
}

# Database & Schemas
resource "snowflake_database" "core_db" {
  name = "CORE_DB"
}

resource "snowflake_schema" "staging" {
  name = "STAGING"
  database = snowflake_database.core_db.name
}

resource "snowflake_schema" "transformed" {
  name = "TRANSFORMED"
  database = snowflake_database.core_db.name
}

resource "snowflake_schema" "analytics" {
  name = "ANALYTICS"
  database = snowflake_database.core_db.name
}

# Roles
resource "snowflake_account_role" "developer" {
  name = "DEVELOPER"
}

resource "snowflake_account_role" "analyst" {
  name = "ANALYST"
}

resource "snowflake_account_role" "reports_reader" {
  name = "REPORTS_READER"
}

# All Privileges Grants for developer
resource "snowflake_grant_privileges_to_account_role" "core_db_all_privileges_to_developer" {
  account_role_name = snowflake_account_role.developer.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.core_db.name
  }
  all_privileges = true
}

resource "snowflake_grant_privileges_to_account_role" "core_db_schemas_all_privileges" {
  account_role_name = snowflake_account_role.developer.name
  on_schema {
    all_schemas_in_database = snowflake_database.core_db.name
  }
  all_privileges = true
}

# Integration Grants
resource "snowflake_grant_privileges_to_account_role" "azure_to_developer" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.developer.name
  on_account_object {
    object_type = "INTEGRATION"
    object_name = "AZURE_INTEGRATION"
  }
}

resource "snowflake_grant_privileges_to_account_role" "notification_to_developer" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.developer.name
  on_account_object {
    object_type = "INTEGRATION"
    object_name = "AZURE_NOTIFICATION"
  }
}

# Warehouse Grants
resource "snowflake_grant_privileges_to_account_role" "usage_backend_dev" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.developer.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.xs_backend.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_dev_dev" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.developer.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.xs_dev.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_analytics_analyst" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.analyst.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.xs_analytics.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_analytics_reader" {
  privileges = ["USAGE"]
  account_role_name = snowflake_account_role.reports_reader.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.xs_analytics.name
  }
}
