use database core_db;
use schema staging;


create table raw_game_events(
    game_id int not null,
    event_id varchar(255) default md5(concat(game_id, minute, type, club_id, player_id, coalesce(player_in_id, -1))) primary key, -- skip in pipe -- all columns in MD5 have not null constraints so no need for coalesce
    minute int not null,
    type varchar(30) not null,
    club_id int not null,
    player_id int not null,
    description varchar(100),
    player_in_id float,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);