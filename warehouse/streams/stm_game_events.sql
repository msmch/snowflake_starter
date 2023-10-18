use database core_db;
use schema staging;


create stream stm_game_events on table raw_game_events;