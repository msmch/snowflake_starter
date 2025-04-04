from date_type_detector import analyze_dataframe
import pandas as pd


def use_db_schema(db_name, schema) -> str:
    sql = f"use database {db_name};\n"
    sql += f"use schema {schema};\n\n\n"
    return sql
    

def column_details(row: str) -> list:
    """
    Return two element list with column name [0] and data type [1].
    """
    items = row.strip().split(" ")
    items = [i.replace(",", "") for i in items]
    return items[:2]


def starting_row(rows: list) -> int:
    for i, r in enumerate(rows):
        if "create table" in r:
            return i
    return -1


def table_name(row: str) -> str:
    table_name = row.split(" ")[-1]
    table_name = table_name.strip()
    if table_name.endswith("("):
        table_name = table_name[:-1]
    return table_name


def get_columns(rows: list, first_row: int) -> list:
    columns = [column_details(row) for row in rows[first_row+1:-1]]
    columns = [c[0] for c in columns]
    return columns


def get_primary_key(rows: list) -> str:
    for row in rows:
        if "primary key" in row:
            return column_details(row)[0]
    return None


def convert_date_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Function recognises and converts date type columns to datetime dtype"""
    date_columns = analyze_dataframe(df)
    cols_for_conversion = [k for k, v in date_columns.items() if v]
    df[cols_for_conversion] = df[cols_for_conversion].apply(pd.to_datetime)
    return df
