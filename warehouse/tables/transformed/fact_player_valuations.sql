use database core_db;
use schema transformed;


create table fact_player_valuations(
    player_id int not null,
    last_season int not null,
    datetime timestamp not null,
    date date not null,
    dateweek date not null,
    market_value_in_eur int not null,
    n int not null,
    current_club_id int not null,
    player_club_domestic_competition_id varchar(20) not null,
    valuation_id varchar(255) default md5(concat(player_id, date, market_value_in_eur)) primary key, -- skip in pipe -- all columns in MD5 have not null constraints so no need for coalesce
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);