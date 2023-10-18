use database core_db;
use schema staging;


create stream stm_clubs on table raw_clubs;