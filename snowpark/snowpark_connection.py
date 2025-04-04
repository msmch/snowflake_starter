import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from snowflake.snowpark import Session



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
    # TODO: in full scope application the below should be stored in env variables
    connection_params = {
        "account": "cluould-aj15446",
        "user": "snowpark_user",
        "private_key": get_pkb(),
        "role": "developer",
        "warehouse": "xs_snowpark",
        "database": "core_db",
        "schema": "staging"
    }
    session = Session.builder.configs(connection_params).create()
    return session