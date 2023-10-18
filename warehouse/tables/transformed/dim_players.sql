use database core_db;
use schema transformed;


create table dim_players(
    player_id int not null primary key,
    first_name varchar(30),
    last_name varchar(40) not null,
    name varchar(50) not null,
    last_season int not null,
    current_club_id int not null,
    player_code varchar(50) not null,
    country_of_birth varchar(50),
    city_of_birth varchar(100),
    country_of_citizenship varchar(40),
    date_of_birth date,
    sub_position varchar(30),
    position varchar(30) not null,
    foot varchar(20),
    height_in_cm float,
    market_value_in_eur float,
    highest_market_value_in_eur float,
    contract_expiration_date date,
    agent_name varchar(40),
    image_url varchar(150) not null,
    url varchar(100) not null,
    current_club_domestic_competition_id varchar(20) not null,
    current_club_name varchar(40),
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);