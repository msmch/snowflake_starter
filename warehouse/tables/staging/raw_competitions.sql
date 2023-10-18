use database core_db;
use schema staging;


create table raw_competitions(
    competition_id varchar(20) not null primary key,
    competition_code varchar(100) not null,
    name varchar(100) not null,
    sub_type varchar(100) not null,
    type varchar(30) not null,
    country_id int not null,
    country_name varchar(30),
    domestic_league_code varchar(20),
    confederation varchar(20) not null,
    url varchar(150) not null,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);