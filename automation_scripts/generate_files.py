import os
import sys

from dotenv import load_dotenv

sys.path.append('../')
from automation_scripts.orchestrator import Orchestrator
from automation_scripts.utils.file_related import get_files


if os.getenv("ENVIRONMENT", "DEV") == "DEV":
    load_dotenv()


def get_data_path() -> str:
    return os.getenv("TF_VAR_SNOWFLAKE_STARTER_LOCAL_FILES_PATH")


def handler() -> str:
    main_log = {"status": 200}

    data_path = get_data_path()
    for file in get_files(data_path):
        orc = Orchestrator(data_path, file)
        exec_log = orc.orchestrate()
        main_log[file] = exec_log
        if exec_log['status'] != 200:
            main_log["status"] = 500
    return main_log


if __name__ == '__main__':
    resp = handler()
    print(resp)