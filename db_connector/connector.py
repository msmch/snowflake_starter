import logging
import os

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from dotenv import load_dotenv
from snowflake.snowpark import Session

if os.getenv("ENV", "development") == "development":
    load_dotenv()


def get_private_key() -> bytes:
    pem_file = os.getenv(f'SNOWPARK_PRIVATE_KEY')
    with open(pem_file, 'rb') as pem_in:
        pemlines = pem_in.read()
    return pemlines
    

def get_pkb() -> bytes:
    pemlines = get_private_key()
    p_key = serialization.load_pem_private_key(
        pemlines,
        password=None,
        backend=default_backend()
    )
    pkb = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    return pkb


def open_session():
    connection_params = {
        "account": os.getenv("SNOWFLAKE_ACCOUNT"),
        "user": os.getenv("SNOWPARK_USER"),
        "private_key": get_pkb(),
        "role": os.getenv("SNOWPARK_ROLE"),
        "warehouse": os.getenv("SNOWPARK_WAREHOUSE"),
        "database": os.getenv("SNOWPARK_DB"),
        "schema": os.getenv("SNOWPARK_SCHEMA")
    }
    session = Session.builder.configs(connection_params).create()
    return session


class SnowparkConnector:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.session = open_session()

    def __enter__(self):
        return self.session

    def __exit__(self, exc_type, exc_value, traceback):
        self.session.close()