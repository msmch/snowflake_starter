import os
import sys
sys.path.append('../')

from snowpark.connector import SnowparkConnector

with SnowparkConnector() as conn:
    print(conn.sql("show databases;").collect())