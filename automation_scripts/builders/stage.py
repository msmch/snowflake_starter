import os
from .base import BaseBuilder


class StageBuilder(BaseBuilder):
    """This class is used for generating SQL statements to create data stages in Snowflake. 
    It specifies the URL and file format for the data stage.
    
    NEVER use this automation class for dynamical SQL composition in PROD application. It's supposed to automate the warehouse 
    creation and using the f-string approach in dynamic SQL composition is extremely dangerous because it's exposing your code 
    to SQL Injections. For that purpose check ORM, like Snowpark or SQLAlchemy.
    """

    def __init__(self, file_format: str = 'csv_with_header'):
        super().__init__()
        self.url = self.get_azure_container_url()
        self.file_format = file_format

    def get_azure_container_url(self) -> str:
        storage_account_name = os.getenv("TF_VAR_SNOWFLAKE_STARTER_STORAGE_ACC")
        container_name = os.getenv("TF_VAR_SNOWFLAKE_STARTER_STORAGE_ACC_CONT")
        # Check if the variables are set
        if not storage_account_name or not container_name:
            raise ValueError("One or both environment variables are not set. Please ensure TF_VAR_SNOWFLAKE_STARTER_STORAGE_ACC and TF_VAR_SNOWFLAKE_STARTER_STORAGE_ACC_CONT are defined.")
        container_url = f"https://{storage_account_name}.blob.core.windows.net/{container_name}"
        return container_url

    def build_statement(
        self, 
        file: str, 
        db_name: str|None = None,
        schema_name: str|None = None
    ) -> str:
        file_name = file.split('.')[0]
        target_url = f'{self.url}/{file_name}/'  

        base_sql = f"""
            create stage stg_{file_name}
            url = '{target_url}'
            storage_integration = azure_integration
            file_format = {self.file_format};
        """

        sql = self.prettify_statement(
            base_sql,
            specify_db_schema=True,
            db_name=db_name or self.core_database,
            schema_name=schema_name or self.staging_schema
        )
        return sql
