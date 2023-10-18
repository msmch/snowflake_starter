use database core_db;
use schema staging;


create stream stm_players on table raw_players;