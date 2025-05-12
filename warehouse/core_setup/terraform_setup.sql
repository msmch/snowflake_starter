use role accountadmin;

-- Create service user for Terraform
create role if not exists tf_admin_role;

-- grant necesairly access
grant create warehouse on account to role tf_admin_role;
grant create database on account to role tf_admin_role;
grant create role on account to role tf_admin_role;
grant create integration on account to role tf_admin_role;
grant execute task on account to role tf_admin_role;


-- service user for terrafor,
create user if not exists tf_admin_user
  default_role = tf_admin_role
  must_change_password = false
  rsa_public_key = '<insert_terraform_public_key>';

-- grant role to the user
grant role tf_admin_role to user tf_admin_user;
-- grant role tf_admin_role to user msmch; -- it's my personal user, replace it with your master user

grant usage on integration azure_integration to role tf_admin_role with grant option;
grant usage on integration azure_notification to role tf_admin_role with grant option;