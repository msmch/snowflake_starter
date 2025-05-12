
/* This script set Snowpark user that allows me to interact with my database using python. */
use role accountadmin;


create warehouse xs_snowpark
with 
warehouse_size = 'XSMALL';

/* Separate Snowpark user so we can use key pair authentication */
create user snowpark_user 
password = '<a secure password>'  -- fill it when running the command, don't keep password in the repo
default_role = developer
default_warehouse = xs_snowpark
must_change_password = true;

alter user snowpark_user set rsa_public_key = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5EGDRcT3K652Jr4x8XYmcLe6F6gU0GnGxCPGQvRwBZUIc7rzVsFPiXD/QLDyKKokK2bvz6dGXqGY8/Q1SuLAwNPewvQ1ggAleEWseb3ojUmXQT2iN9orDRyfAY5H1H8YCpH91+Wvw/WvVrWbxiQuYAU9HKHNRBsN8gt36ssfMpAM6UR54cPVJ8/chU9YVH3xLBGIX167WAYeTUyrxGjOLbirKWpxiyIrQKiOzDkmgFFZA7ZwTgtSdqEEZm6h4ZKj7deqULrg8xUlC7QyWA9sNHGt4S0Kdaj59fcCfo3FPMuOIrxkRIYtRg4cn4/pXLT4+lWJCpDhBbR7jy4AyvoJtQIDAQAB';
alter user snowpark_user set password = null;
alter user snowpark_user set mins_to_bypass_mfa = 0;

grant role developer to user snowpark_user;
grant usage on warehouse xs_snowpark to role developer;
