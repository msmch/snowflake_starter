use database core_db;
use schema staging;


create file format csv_with_header
type = csv
field_delimiter = ','
field_optionally_enclosed_by='"'
skip_header = 1
null_if = ('null', 'Null', 'NULL')
empty_field_as_null = true
compression = auto
date_format = 'yyyy-mm-dd';