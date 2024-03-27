import os
import glob

def rename_jsx_to_js(directory):
    for filename in glob.iglob(directory + '**/*.jsx', recursive=True):
        base = os.path.splitext(filename)[0]
        os.rename(filename, base + '.js')

# Call the function with the directory you want to start in
rename_jsx_to_js('./')