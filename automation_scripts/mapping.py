import os

BASE_DIR = "../warehouse/"

# you can map as many tables you want by adding them into the below dictionary
TABLES_MAPPING = {
    "raw_appearances": "dim_appearances",
    "raw_club_games": "fact_club_games",
    "raw_clubs": "dim_clubs",
    "raw_competitions": "dim_competitions",
    "raw_player_valuations": "fact_player_valuations",
    "raw_players": "dim_players",
}

# folders order for deployment
FOLDERS_ORDER = [
    "file_formats",
    "tables",
    "stages",
    "streams",
    "pipes",
    "tasks"
]

IGNORE_FOLDERS = ["core_setup"]