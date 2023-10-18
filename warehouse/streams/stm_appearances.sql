use database core_db;
use schema staging;


create stream stm_appearances on table raw_appearances;