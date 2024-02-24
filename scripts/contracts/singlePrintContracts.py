import os
import re

def extract_info_from_sol_files(contracts_directory, output_directory):
    # Ensure the output directory exists
    output_directory_path = os.path.abspath(output_directory)
    if not os.path.exists(output_directory_path):
        os.makedirs(output_directory_path)

    def write_to_file(out_file, content):
        print(content, file=out_file)

    def process_sol_files(out_file, root, sol_files):
        for sol_file in sol_files:
            file_path = os.path.join(root, sol_file)
            write_to_file(out_file, "\n-- File: " + sol_file)

            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            # Extract import lines
            import_lines = re.findall(r'^import .*;$', content, re.MULTILINE)
            if import_lines:
                write_to_file(out_file, "---- Imports:")
                for line in import_lines:
                    write_to_file(out_file, "------ " + line)

            # Extract functions and state variables using regex
            state_vars = re.findall(r'(?:event|string|address|uint256|int256|bool|mapping|modifier|struct|public|private|internal|external)\s+([a-zA-Z0-9_]+\s+[a-zA-Z0-9_]+)\s*(?:=.*?;|;)', content)
            functions = re.findall(r'\bfunction\s+([a-zA-Z0-9_]+)\s*\((.*?)\)\s*(?:public|private|internal|external)', content)

            if state_vars:
                write_to_file(out_file, "---- State Variables:")
                for var in state_vars:
                    var = re.sub(r'\s*=\s*.*?;', ';', var)
                    write_to_file(out_file, "------ " + var)
                    
            if functions:
                write_to_file(out_file, "---- Functions:")
                for func in functions:
                    func_name = func[0]
                    func_params = re.sub(r'\s*=\s*.*?,', ',', func[1])
                    func_params = re.sub(r'\s*=\s*.*?\)', ')', func_params)
                    write_to_file(out_file, "------ " + func_name + " requires: " + func_params)

    for folder_name in os.listdir(contracts_directory):
        folder_path = os.path.join(contracts_directory, folder_name)
        if os.path.isdir(folder_path):
            output_file_path = os.path.join(output_directory_path, f"{folder_name}Print.txt")

            with open(output_file_path, 'w', encoding='utf-8') as out_file:
                write_to_file(out_file, "Contracts Summary: Functions and State Variables")

                for root, _, files in os.walk(folder_path):
                    sol_files = [f for f in files if f.endswith('.sol')]
                    if sol_files:
                        write_to_file(out_file, "\nFolder: " + folder_name)
                        process_sol_files(out_file, root, sol_files)

# Define the base directory to analyze and the output directory
contracts_directory = "contracts/facets"
output_directory = "scripts/contracts/prints"

extract_info_from_sol_files(contracts_directory, output_directory)