from .base import BaseBuilder
from .config import TRANSFORMED_SCHEMA

import sys
sys.path.append('../')
from utils.basic import starting_row, get_primary_key, get_columns


class MergeBuilderError(Exception):
    """Custom error for MergeBuilder specific issues"""
    pass


class MergeBuilder(BaseBuilder):
    """
    This class is used for generating SQL statements for merging data from staging tables into transformed tables. 
    It analyzes the structure of the source file and generates SQL code for merging based on primary keys.

    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.
    """

    def __init__(self):
        super().__init__()
        self.columns = None
        self.id_col = None

    def analyze_staging_table(self, fpath: str) -> None:
        """
        Variable fpath is a file path to the staging table that will be used as a source for synch with the transformed table.
        We want the latest and unique data for each primary key from the staging table. Based on that Snowflake will merge data into 
        the target table.
        """
        with open(fpath, 'r') as file:
            rows = file.readlines()
        first_row = starting_row(rows)
        self.columns = get_columns(rows, first_row)
        self.id_col = get_primary_key(rows[first_row:])

    def generate_set_str(self, columns: list, ident: str) -> str:
        return ',\n'.join([f'{ident}dest.{c} = src.{c}' for c in columns])

    def build_statement(
            self,            
            source_tbl: str, 
            target_tbl: str, 
            db_name: str|None = None,
            source_schema: str|None = None, 
            target_schema: str = TRANSFORMED_SCHEMA,
            only_merge: bool = True
        ) -> str:
        if self.columns is None:
            raise MergeBuilderError('Source file not analyzed. You need to run analyze_src_file() first.')
        
        set_str = self.generate_set_str(self.columns, self.ident*4)
        columns_str = ','.join(self.columns)
        values_str = ', '.join([f'src.{c}' for c in self.columns])

        sql = f"""
        merge into {target_schema}.{target_tbl} as dest
        using (
            select *
            from {source_tbl}
            where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
            qualify 1 = row_number() over (partition by {self.id_col} order by add_timestamp desc)
        ) as src
        on dest.{self.id_col} = src.{self.id_col}
        when matched then
            update set 
            {set_str}
        when not matched then
            insert ({columns_str})
            values ({values_str});
        """
        
        if only_merge:
            specify_db_schema = False
        else:
            specify_db_schema = True

        sql = self.prettify_statement(
            sql,
            specify_db_schema=specify_db_schema,
            db_name=db_name or self.core_database ,
            schema_name=source_schema or self.staging_schema
        )
        return sql
        
