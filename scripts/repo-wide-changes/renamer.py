import os

def rename_files(directory):
    for root, dirs, files in os.walk(directory):
        for name in dirs + files:
            if name.startswith("-"):
                os.rename(os.path.join(root, name), os.path.join(root, name[1:]))
                print(f'Renamed: {os.path.join(root, name)} to {os.path.join(root, name[1:])}')

if __name__ == '__main__':
    # Get the parent directory of the script, which is assumed to be the root of the repo
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    rename_files(repo_root)
