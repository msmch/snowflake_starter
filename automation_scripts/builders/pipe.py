from .base import BaseBuilder
from .config import NOTIFICATION_QUEUE

import sys
sys.path.append('../')
from basic_operations import column_details, starting_row, table_name
from file_operations import read_file


class PipeBuilderError(Exception):
    """Custom error for PipeBuilder specific issues"""


class PipeBuilder(BaseBuilder):
    """
    This class is used for generating SQL statements to create data pipelines. It extracts column information from a SQL file 
    and generates the necessary SQL code for data ingestion.

    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.
    """

    def __init__(self) -> None:
        super().__init__()

    def generate_base_statements(
        self, 
        table_name: str,
        integration_name: str = NOTIFICATION_QUEUE
    ) -> None:
        self.sql_copy = [f'copy into {table_name} (\n']
        self.sql_from = ['from (\n', f'{self.ident}select\n' ]
        file_name = table_name[4:]
        self.sql_header = f'create pipe p_{file_name}\n'
        self.sql_header += 'auto_ingest = true\n'
        self.sql_header += f"integration = '{integration_name.upper()}'\nas \n"
        self.stage = f'stg_{file_name}'

    def add_row_to_substatements(self,  i: int, row: str) -> None:
        column_name, dtype = column_details(row)
        copy_line = f'{self.ident}{column_name},\n'

        if dtype == 'date':
            from_line = f"{self.ident*2} to_date(left(stg.${i}, 10), 'YYYY-MM-DD'), {self.ident}-- {column_name}\n"
        else:
            from_line = f'{self.ident*2} stg.${i}, {self.ident}-- {column_name}\n'
            
        self.sql_copy.append(copy_line)
        self.sql_from.append(from_line)
    
    def join_sub_statements(self) -> str:
        for statement in [self.sql_copy, self.sql_from]:
            statement[-1] = statement[-1].replace(',', '')
            statement.append(')\n')
        self.sql_from[-1] = f'{self.ident}from @{self.stage} stg\n);'
        sql_copy = ''.join(self.sql_copy)
        sql_from = ''.join(self.sql_from)
        return self.sql_header + sql_copy + sql_from

    def generate_sql(self, content: list, first_row: int) -> str:
        rows = content[first_row + 1:]
        i = 1
        for row in rows:
            if 'skip in pipe' in row:
                continue
            if 'add_timestamp' in row: 
                break
            self.add_row_to_substatements(i, row)
            i += 1
        sql = self.join_sub_statements()
        return sql

    def build_statement(
        self,
        fpath: str, 
        db_name: str|None = None,
        schema_name: str|None = None
    ) -> str:
        content = read_file(fpath)
        first_row = starting_row(content)
        if first_row == 0:
            raise PipeBuilderError('CREATE TABLE clause is not included in the file.')

        table = table_name(content[first_row])
        self.generate_base_statements(table)

        sql = self.generate_sql(content, first_row)
        sql = self.prettify_statement(
            sql,
            specify_db_schema=True,
            db_name=db_name or self.core_database,
            schema_name=schema_name or self.staging_schema
        )
        return sql
