use database core_db;
use schema transformed;


create table dim_clubs(
    club_id int not null primary key,
    club_code varchar(50) not null,
    name varchar(40),
    domestic_competition_id varchar(20) not null,
    total_market_value float,
    squad_size int not null,
    average_age float,
    foreigners_number int not null,
    foreigners_percentage float,
    national_team_players int not null,
    stadium_name varchar(100) not null,
    stadium_seats int not null,
    net_transfer_record varchar(20) not null,
    coach_name float,
    last_season int not null,
    url varchar(100) not null,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);