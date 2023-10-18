use database core_db;
use schema staging;


create table raw_games(
    game_id int not null primary key,
    competition_id varchar(20) not null,
    season int not null,
    round varchar(40) not null,
    date date not null,
    home_club_id int not null,
    away_club_id int not null,
    home_club_goals int not null,
    away_club_goals int not null,
    home_club_position int not null,
    away_club_position int not null,
    home_club_manager_name varchar(40),
    away_club_manager_name varchar(50),
    stadium varchar(100),
    attendance float,
    referee varchar(100),
    url varchar(150) not null,
    home_club_name varchar(40),
    away_club_name varchar(40),
    aggregate varchar(20) not null,
    competition_type varchar(30) not null,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);