from .config import CORE_DATABASE, STAGIC_SCHEMA

import sys
sys.path.append('../')
from utils.basic import use_db_schema


class BaseBuilderError(Exception):
    """Default exception used to handle BaseBuilder errors"""
    pass


class BaseBuilder:
    """ This is the base class for other builder classes. It provides some common methods for formatting and prettifying SQL statements.
    
    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.
    """

    def __init__(self) -> None:
        self.ident = ' '*4
        self.core_database = CORE_DATABASE
        self.staging_schema = STAGIC_SCHEMA

    def min_left_ident(self, sql: str) -> int:
        min_ident = float('inf')
        for line in sql.split('\n'):
            if line.strip():
                ident = len(line) - len(line.lstrip())
                min_ident = min(min_ident, ident)
        return min_ident

    def no_empty_row_at_top(self, sql: str) -> str:
        rows = sql.split('\n')
        for i, r in enumerate(rows):
            if len(r.strip()) > 0:  
                break
        return '\n'.join(rows[i:])      

    def shift_statement_left(self, sql: str) -> str:
        min_ident = self.min_left_ident(sql)
        return '\n'.join([line[min_ident:] for line in sql.split('\n')])

    def prettify_statement(
            self, 
            sql: str, 
            specify_db_schema: bool = False,
            **kwargs
        ) -> str:
        sql = self.no_empty_row_at_top(sql)
        sql = self.shift_statement_left(sql)
        if specify_db_schema:
            if "db_name" not in kwargs:
                raise BaseBuilderError("'db_name' must be provided in kwargs if 'use_db_schema' is set to True")
            if "schema_name" not in kwargs:
                raise BaseBuilderError("'schema_name' must be provided in kwargs if 'use_db_schema' is set to True")
            sql = use_db_schema(kwargs['db_name'], kwargs['schema_name']) + sql
        return sql