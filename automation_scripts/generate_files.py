import os
import json

import sys
sys.path.append('../')
from automation_scripts.orchestrator import Orchestrator
from automation_scripts.file_operations import get_files
from automation_scripts.mapping import BASE_DIR


def handler() -> str:
    tables = get_files(os.path.join(BASE_DIR, 'tables/staging/'))
    for table in tables:
        orc = Orchestrator(table)
        exec_log = orc.orchestrate()

        if exec_log['status'] == 200:
            resp = f'All files generated successfully. {exec_log}'
        else:
            resp = f'Executed with errors. {exec_log}'

    return resp


if __name__ == '__main__':
    resp = handler()
    print(resp)