from tqdm import tqdm

import sys
sys.path.append('../')
from azure_connector.upload import upload_file 
from automation_scripts.file_operations import get_files


PATH = '../data/'


def upload_files() -> None:
    files = get_files(PATH)

    pbar = tqdm(
        desc='Uploading files',
        total = len(files)
    )
    for i, file in enumerate(files):
        target_name = file.split('.')[0]
        upload_file(
            fpath = f'{PATH}/{file}',
            container = 'snowflake-starter',
            target = target_name
        )
        pbar.update(i)
    pbar.close()


def handler() -> str:
    resp = 'Files loaded successfully.'
    try:
        upload_files()
    except Exception as e:
        resp = f'Files upload failed because of the following error: {e}'

    return resp


if __name__ == '__main__':
    resp = handler()
    print(resp)