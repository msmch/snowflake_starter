use database core_db;
use schema staging;


create stream stm_club_games on table raw_club_games;