import os


def get_files(path: str) -> list:
    file_names = []
    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            if not os.path.isdir(file_path):
                file_names.append(file)
    return file_names


def read_file(fpath: str) -> list:
    if not os.path.exists(fpath):
        raise FileNotFoundError(f"File {fpath} doesn't exist")
    with open(fpath, 'r') as file:
        return file.readlines()


def write_to_file(fpath: str, content: str, force: bool = False) -> str:
    directory = '/'.join(fpath.split('/')[:-1])
    if not os.path.isdir(directory):
        os.makedirs(directory) 

    if os.path.exists(fpath) and force == False:
        return f'File {fpath} already exists. Set force flag to True if you want to override that.'
    
    with open(fpath, 'w') as file:
        file.writelines(content)
        return (f'File {fpath} saved successfully.' )
