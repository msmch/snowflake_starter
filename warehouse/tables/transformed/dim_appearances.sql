use database core_db;
use schema transformed;


create table dim_appearances(
    appearance_id varchar(30) not null primary key,
    game_id int not null,
    player_id int not null,
    player_club_id int not null,
    player_current_club_id int not null,
    date date,
    player_name varchar(50),
    competition_id varchar(20) not null,
    yellow_cards int not null,
    red_cards int not null,
    goals int not null,
    assists int not null,
    minutes_played int not null,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);