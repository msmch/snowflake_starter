import os
import re
import logging

import pandas as pd

import sys
sys.path.append('../')
from builders import (
    PipeBuilder, MergeBuilder, TaskBuilder, StreamBuilder,
    TableBuilder, StageBuilder
)
from file_operations import read_file, write_to_file
from mapping import BASE_DIR, TABLES_MAPPING


logging.basicConfig(
    level = logging.DEBUG,
    format = "%(asctime)s - %(name)s %(levelname)s: %(message)s",
    datefmt = "%Y-%m-%d %H:%M:%S",
    force = True
)


# get file names
class Orchestrator:
    BASE_DIR = BASE_DIR
    STAGING_DIR = os.path.join(BASE_DIR, 'tables/staging/')
    TRANSFORMED_DIR = os.path.join(BASE_DIR, 'tables/transformed/')
    PIPES_DIR =  os.path.join(BASE_DIR, 'pipes/')
    STREAMS_DIR = os.path.join(BASE_DIR, 'streams/') 
    TASKS_DIR = os.path.join(BASE_DIR, 'tasks/') 
    TABLES_MAPPING = TABLES_MAPPING

    def __init__(self, data_path: str, file_name: str):
        self.logger = logging.getLogger(__name__)
        self.data_path = data_path
        self.file_name = file_name
        self.full_path = os.path.join(data_path, file_name)
        self.staging_tbl = f"raw_{file_name.split('.')[0]}"
        self.core_name  = self.staging_tbl[4:]
        self.transformed_tbl = self.TABLES_MAPPING.get(self.staging_tbl)
        self.build_staging_table()

    def build_staging_table(self):
        df = pd.read_csv(self.full_path)
        tbl_builder = TableBuilder(df)
        table_ddl = tbl_builder.build_statment(self.staging_tbl)
        tbl_status = write_to_file(
            fpath = f'../warehouse/tables/staging/{self.staging_tbl}.sql',
            content = table_ddl
        )
        return tbl_status

    def build_stage(self):
        stg_builder = StageBuilder()
        stage_ddl = stg_builder.build_statement(self.core_name)
        stg_status = write_to_file(
            fpath = f'../warehouse/stages/stg_{self.core_name}.sql',
            content = stage_ddl
        )
        return stg_status

    def generate_pipe(self) -> str:
        fpath = self.STAGING_DIR + self.staging_tbl + ".sql"
        builder = PipeBuilder()
        sql = builder.build_statement(fpath)
        return sql

    def generate_transformed_tables(self) -> dict:
        transformed_schema = self.TRANSFORMED_DIR.split('/')[-2]
        statements = {}
        for src, dest in self.TABLES_MAPPING.items():
            rows = read_file(self.STAGING_DIR + f'{src}.sql')
            sql = ''.join(rows)
            sql = re.sub(
                'use schema .*;', 
                f'use schema {transformed_schema};', 
                sql
            )
            sql = re.sub(
                f'create table {src}', 
                f'create table {dest}', 
                sql
            )
            statements[dest] = sql
        return statements

    
    def generate_stream(self) -> str:
        stm_builder = StreamBuilder()
        sql = stm_builder.build_statement(self.staging_tbl)
        return sql


    def generate_merge(self) -> str:
        m_builder = MergeBuilder()
        m_builder.analyze_src_file(self.STAGING_DIR + self.core_name + "sql")

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

    
    def orchestrate(self) -> dict:
        exec_log = {
            'status': 200,
            'errors': {}
        }
        
        try:
            pipe = self.generate_pipe()
            fpath = self.PIPES_DIR + f'p_{self.core_name}.sql'
            write_status = write_to_file(fpath, pipe)
            self.logger.info(write_status)
        except Exception as e:
            exec_log['status'] = 500
            exec_log['errors']['pipe'] = e
        
        try:
            stream = self.generate_stream()
            fpath = self.STREAMS_DIR + f'stm_{self.core_name}.sql'
            write_status = write_to_file(fpath, stream)
            self.logger.info(write_status)
        except Exception as e:
            exec_log['status'] = 500
            exec_log['errors']['stream']  = e

        try:
            transformed_tables = self.generate_transformed_tables()
            for tbl_name, sql in transformed_tables.items():
                fpath = self.TRANSFORMED_DIR + f'{tbl_name}.sql'
                write_status = write_to_file(fpath, sql)
                self.logger.info(write_status)
        except Exception as e:
            exec_log['status'] = 500
            exec_log['errors']['transformed_tables']  = e

        if self.transformed_tbl is None:
            self.logger.info(f'Skipping merge generation. Table {self.staging_tbl} not included in tables mapping.')
            return exec_log

        try:
            merge_task = self.generate_merge_task()
            fpath = self.TASKS_DIR + f'tsk_merge_{self.core_name}.sql'
            write_status = write_to_file(fpath, merge_task)
            self.logger.info(write_status)
        except Exception as e:
            exec_log['status'] = 500
            exec_log['errors']['merge_task']  = e
        return exec_log