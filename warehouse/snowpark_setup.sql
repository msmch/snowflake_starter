
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

alter user snowpark_user set rsa_public_key = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1Tbogs1Qin4wEbV4z/Gde59V9oA2wTfDcfR0wbmMxP7owfG8mdPlHIboz9rehAkcFRzys23FCESavVbIgI2KHUzdNVZqcPFyQ14W9MJZ2izsIEMUsz005Q3Ken4UkpuJa26cN7fguMYsW9JIOTfaNze6AOUhU3nP8IGJKhNrp0XGAG3c2Ujo8tABFuGS3UL3Y5nQxHelMPn9x2uSrq2NwQPGq3vzQdmJFEd/hJ0s+LP+AhALsuRwigaLUqWnMb2CSk1/ZWs+oEPFSF+9iiJGTCChtq+j06xgG4jKsXWON6QaUJBulrXm6fg5o/6oxryl3W2aI94ID01C+/u3pHaw/wIDAQAB';
alter user snowpark_user set password = null;
alter user snowpark_user set mins_to_bypass_mfa = 0;

grant role developer to user snowpark_user;
grant usage on warehouse xs_snowpark to role developer;
