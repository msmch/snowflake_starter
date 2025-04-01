from .base import BaseBuilder

import sys
sys.path.append('../')
from basic_operations import use_db_schema


class StreamBuilder(BaseBuilder):
    """
    This class is used for generating SQL statements to create streams on tables in Snowflake. 
    Streams are used for real-time data replication and change tracking.

    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.       
    """

    def __init__(self):
        super().__init__()
    
    def build_statement(
        self, 
        table_name: str, 
        db_name: str = None, 
        schema_name: str = None
        ):
        db_name = db_name or self.core_database
        schema_name = schema_name or self.staging_schema
        
        core = '_'.join(table_name.split('_')[1:])
        stream_name = f'stm_{core}'
        sql = use_db_schema(db_name, schema_name)
        sql += f'create stream {stream_name} on table {table_name};'

        return sql
