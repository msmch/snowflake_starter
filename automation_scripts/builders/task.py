from .base import BaseBuilder


class TaskBuilder(BaseBuilder):
    """
    This class is used for generating SQL statements to create Snowflake tasks. It allows you to define the SQL code 
    that should be executed by the task and set task-specific parameters such as the warehouse, frequency, and dependencies.

    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.    
    """

    def __init__(self):
        super().__init__()

    def conditional_elements(self, predecesor: str, frequency: str, stream_name: str) -> str:
        after_task, schedule, where_stream_has_data = '', '', ''

        if predecesor:
            after_task = f'after {predecesor}\n'
        if frequency:
            schedule = f"schedule = '{frequency}'\n"
        if stream_name:
            where_stream_has_data = f"when system$stream_has_data('{stream_name}')\n"

        assert len(after_task) == 0 or len(schedule) == 0, "You cannot provide both 'frequency' and 'predecesor'."

        return after_task, schedule, where_stream_has_data
    
    def build_statement(
        self, 
        task_body: str,
        task_name: str, 
        warehouse: str = 'xs_backend',
        db_name: str|None = None,
        schema_name: str|None = None, 
        frequency: str|None = None,
        stream_name: str|None = None, 
        predecesor: str|None = None,
        specify_db_schema: bool = False,
        ) -> str:

        after_task, schedule, where_stream_has_data = self.conditional_elements(
            predecesor,
            frequency,
            stream_name
        )

        sql = f"""
        create or replace task {task_name}
        warehouse = {warehouse}
        """
        sql = self.shift_statement_left(sql)

        for i in [schedule, after_task, where_stream_has_data]:
            if len(i)> 0:
                sql += i

        sql += f"as \n{task_body}"

        sql = self.prettify_statement(
            sql,
            specify_db_schema=specify_db_schema,
            db_name=db_name or self.core_database,
            schema_name=schema_name or self.staging_schema
        )
        return sql
