import functools
import logging
from os import path
import pandas as pd
import re

import sys
sys.path.append('../')
from builders import (
    PipeBuilder, MergeBuilder, TaskBuilder, StreamBuilder,
    TableBuilder, StageBuilder
)
from utils.file_related import read_file, write_to_file
from mapping import BASE_DIR, TABLES_MAPPING


logging.basicConfig(
    level = logging.DEBUG,
    format = "%(asctime)s - %(name)s %(levelname)s: %(message)s",
    datefmt = "%Y-%m-%d %H:%M:%S",
    force = True
)
logger = logging.getLogger(__name__)


def log_output(func):
    """
    Decorator that logs the output of a function at the INFO level using self.logger.
    Assumes the function is a method of a class with a 'logger' attribute.
    """
    @functools.wraps(func)
    def wrapper(self, *args, **kwargs):
        result = func(self, *args, **kwargs)
        # Use self.logger from the instance
        self.logger.info(f"Function '{func.__name__}' output: {result}")
        return result
    return wrapper


# get file names
class Orchestrator:
    BASE_DIR = BASE_DIR
    STAGING_DIR = path.join(BASE_DIR, "tables/staging/")
    STAGES_DIR = path.join(BASE_DIR, "stages/")
    TRANSFORMED_DIR = path.join(BASE_DIR, "tables/transformed/")
    PIPES_DIR =  path.join(BASE_DIR, "pipes/")
    STREAMS_DIR = path.join(BASE_DIR, "streams/") 
    TASKS_DIR = path.join(BASE_DIR, "tasks/") 
    TABLES_MAPPING = TABLES_MAPPING

    def __init__(self, data_path: str, file_name: str):
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"Working on file {file_name}.")
        self.data_path = data_path
        self.file_name = file_name
        self.full_path = path.join(data_path, file_name)
        self.staging_tbl = f"raw_{file_name.split('.')[0]}"
        self.core_name  = self.staging_tbl[4:]
        self.transformed_tbl = self.TABLES_MAPPING.get(self.staging_tbl)

    def generate_staging_table(self) -> str:
        df = pd.read_csv(self.full_path)
        tbl_builder = TableBuilder(df)
        sql = tbl_builder.build_statment(self.staging_tbl)
        return sql

    def generate_stage(self) -> str:
        stg_builder = StageBuilder()
        sql = stg_builder.build_statement(self.core_name)
        return sql

    def generate_pipe(self) -> str:
        fpath = path.join(self.STAGING_DIR, f"{self.staging_tbl}.sql")
        builder = PipeBuilder()
        sql = builder.build_statement(fpath)
        return sql

    def generate_transformed_table(self) -> str|None:
        transformed_schema = self.TRANSFORMED_DIR.split('/')[-2]
        if self.transformed_tbl is None:
            self.logger.info(f"Staging table {self.staging_tbl} is not included in the transformed schema mapping.")
            return None
        rows = read_file(path.join(self.STAGING_DIR, f'{self.staging_tbl}.sql'))
        sql = ''.join(rows)
        sql = re.sub(
            'use schema .*;', 
            f'use schema {transformed_schema};', 
            sql
        )
        sql = re.sub(
            f'create table {self.staging_tbl}', 
            f'create table {self.transformed_tbl}', 
            sql
        )
        return sql
    
    def generate_stream(self) -> str:
        stm_builder = StreamBuilder()
        sql = stm_builder.build_statement(self.staging_tbl)
        return sql
    
    def generate_merge(self) -> str:
        m_builder = MergeBuilder()
        m_builder.analyze_staging_table(
            path.join(self.STAGING_DIR, f"{self.staging_tbl}.sql")
        )

        sql = m_builder.build_statement(
            self.staging_tbl,
            self.transformed_tbl
        )
        return sql
    
    def generate_merge_task(self) -> str:
        merge_sql = self.generate_merge()
        stream_name = f'stm_{self.core_name}'

        tsk_builder = TaskBuilder()
        main_task_name = f'tsk_merge_into_{self.transformed_tbl}'
        main_task_sql = tsk_builder.build_statement(
            task_body = merge_sql,
            task_name = main_task_name,
            frequency = '1 minute',
            stream_name = stream_name,
            specify_db_schema = True
        )
        main_task_sql += '\n'

        stream_task_name = f'tsk_recreate_{stream_name}'
        stream_task_sql = tsk_builder.build_statement(
            task_body = f'create or replace stream {stream_name} on table {self.staging_tbl};\n\n',
            task_name = stream_task_name,
            predecesor = main_task_name,
            specify_db_schema = False
        )
        
        sql = main_task_sql + stream_task_sql
        sql += f'alter task {stream_task_name} resume;\n'
        sql += f'alter task {main_task_name} resume;\n'
        return sql
    
    def generate_filepath(self, method: str) -> str|None:
        key = method.replace("generate_", "")
        paths = {
            "staging_table": path.join(self.STAGING_DIR, f"{self.staging_tbl}.sql"),
            "stage": path.join(self.STAGES_DIR, f"stg_{self.core_name}.sql"),
            "pipe": path.join(self.PIPES_DIR, f"p_{self.core_name}.sql"),
            "stream": path.join(self.STREAMS_DIR, f"stm_{self.core_name}.sql"),
            "merge_task": path.join(self.TASKS_DIR, f"tsk_merge_{self.core_name}.sql"),
            "transformed_table": path.join(self.TRANSFORMED_DIR, f"{self.transformed_tbl}.sql")
        }
        return paths.get(key)
    
    @log_output
    def script_to_file(self, fpath: str, sql: str) -> str:
        return write_to_file(fpath, sql)

    def orchestrate(self) -> dict:
        exec_log = {
            'status': 200,
            'errors': {}
        }
        
        # List of tasks with their method names, output directories, and file name patterns
        tasks = [
            "generate_staging_table",
            "generate_stage",
            "generate_pipe",
            "generate_stream",
            "generate_merge_task",
            "generate_transformed_table"
        ]
        try:
            for task in tasks:
                # Skip merge task if transformed_tbl is None
                if task == 'merge_task' and self.transformed_tbl is None:
                    self.logger.info(f'Skipping merge generation. Table {self.staging_tbl} not included in tables mapping.')
                    continue

                sql = getattr(self, task)()
                if sql is None:
                    self.logger.warning(f"{task} produced no SQL statement for file {self.file_name}.")
                    continue
                self.script_to_file(self.generate_filepath(task), sql)
        
        except Exception as e:
            exec_log['status'] = 500
            exec_log['errors'][task] = e
            
        self.logger.info("File processing completed.\n")
        return exec_log