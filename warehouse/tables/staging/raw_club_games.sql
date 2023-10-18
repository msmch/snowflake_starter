use database core_db;
use schema staging;


create table raw_club_games(
    game_id int not null,
    club_id int not null,
    club_game_id varchar(250) not null primary key default concat(game_id, '_', club_id) -- skip in pipe
    own_goals int not null,
    own_position int not null,
    own_manager_name varchar(50),
    opponent_id int not null,
    opponent_goals int not null,
    opponent_position int not null,
    opponent_manager_name varchar(50),
    hosting varchar(20) not null,
    is_win int not null,
    add_timestamp timestamp default current_timestamp(),
    edit_timestamp timestamp
);