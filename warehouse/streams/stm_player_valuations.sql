use database core_db;
use schema staging;


create stream stm_player_valuations on table raw_player_valuations;