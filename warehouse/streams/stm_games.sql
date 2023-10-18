use database core_db;
use schema staging;


create stream stm_games on table raw_games;