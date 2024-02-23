import os
import re

def extract_info_from_sol_files(contracts_directory, output_directory):
    # Ensure the output directory exists
    output_directory_path = os.path.abspath(output_directory)
    if not os.path.exists(output_directory_path):
        os.makedirs(output_directory_path)
    
    output_file_path = os.path.join(output_directory_path, "contracts_summary.txt")

    with open(output_file_path, 'w', encoding='utf-8') as out_file:
        def write_to_file(content):
            print(content, file=out_file)

        write_to_file("Contracts Summary: Functions and State Variables")

        for root, dirs, files in os.walk(contracts_directory):
            sol_files = [f for f in files if f.endswith('.sol')]
            if sol_files:
                folder_path = os.path.relpath(root, contracts_directory).replace('\\', '/')
                write_to_file("\nFolder: " + folder_path)

                for sol_file in sol_files:
                    file_path = os.path.join(root, sol_file)
                    write_to_file("---- File: " + sol_file)

                    with open(file_path, 'r', encoding='utf-8') as file:
                        content = file.read()

                    # Extract functions and state variables using regex
                    state_vars = re.findall(r'(?:public|private|internal|external)\s+([a-zA-Z0-9_]+\s+[a-zA-Z0-9_]+)\s*(?:=.*?;|;)' , content)
                    functions = re.findall(r'\bfunction\s+([a-zA-Z0-9_]+)\s*\((.*?)\)\s*(?:public|private|internal|external)', content)

                    if state_vars:
                        write_to_file("-------- State Variables:")
                        for var in state_vars:
                            var = re.sub(r'\s*=\s*.*?;', ';', var)  # Remove default values
                            write_to_file("---------- " + var)
                            
                    if functions:
                        write_to_file("-------- Functions:")
                        for func in functions:
                            func_name = func[0]
                            func_params = re.sub(r'\s*=\s*.*?,', ',', func[1])  # Remove default values
                            func_params = re.sub(r'\s*=\s*.*?\)', ')', func_params)  # Remove default values
                            write_to_file("---------- " + func_name + " requires: " + func_params)

# Define the base directory to analyze and the output directory
contracts_directory = "contracts/facets"
output_directory = "scripts/contracts"

extract_info_from_sol_files(contracts_directory, output_directory)