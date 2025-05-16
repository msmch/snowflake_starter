use role accountadmin;

-- Create service user for Terraform
create role if not exists tf_admin_role;

-- grant necesairly access
grant create warehouse on account to role tf_admin_role;
grant create database on account to role tf_admin_role;
grant create role on account to role tf_admin_role;
grant execute task on account to role tf_admin_role;


-- service user for terrafor,
create user if not exists tf_admin_user
  default_role = tf_admin_role
  must_change_password = false
  rsa_public_key = '<insert_snowpark_public_key>';

-- grant role to the user
grant role tf_admin_role to user tf_admin_user;
-- grant role tf_admin_role to user msmch; -- it's my personal user, replace it with your master user

grant usage on integration azure_integration to role tf_admin_role with grant option;
grant usage on integration azure_notification to role tf_admin_role with grant option;



-- Create service user for Snowpark warehouse and user that allows me to interact with my database using python.
-- Given it's a technical account it will be using a key pair auth and we create it here
create user snowpark_user 
  default_role = developer
  must_change_password = false
  rsa_public_key = '<insert_terraform_public_key>';

grant role developer to user snowpark_user;
grant usage on warehouse xs_snowpark to role developer;
