use database core_db;
use schema staging;


create stream stm_competitions on table raw_competitions;