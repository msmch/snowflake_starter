import os
import sys
sys.path.append('../')
from automation_scripts.orchestrator import Orchestrator
from automation_scripts.file_operations import get_files


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