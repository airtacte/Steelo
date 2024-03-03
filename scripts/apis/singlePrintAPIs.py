import os

def refactor_code_to_generate_multiple_txts(directory):
    # Function to refactor that generates a .txt for each folder
    def list_controllers_routes_and_functions_to_folder(directory):
        # Ensure each folder (not sub-folder) has its own .txt output
        for folder_name in os.listdir(directory):
            folder_path = os.path.join(directory, folder_name)
            if os.path.isdir(folder_path):
                output_directory = "scripts/api_controllers_routes/prints" 
                output_file = os.path.join(output_directory, f"{folder_name}.txt")
                
                with open(output_file, 'w', encoding='utf-8') as out_file:
                    # Function to write to the file
                    def write_to_file(content):
                        print(content, file=out_file)
                    
                    # Print the title
                    write_to_file(f"List of Routes and Controllers in {folder_name}")

                    for root, _, files in os.walk(folder_path):
                        controller_files = [f for f in files if f.endswith('Controller.js')]
                        if controller_files:
                            # Write the sub-folder name to the file
                            sub_folder_name = os.path.relpath(root, folder_path).replace('\\', '/')
                            write_to_file("\nSub-folder: " + sub_folder_name)

                            for controller_file in controller_files:
                                write_to_file("-- File: " + controller_file)

                                with open(os.path.join(root, controller_file), 'r', encoding='utf-8') as file:
                                    lines = file.readlines()
                                    # Search for lines that contain either "router." or "exports."
                                    const_lines = [line.strip() for line in lines if line.strip().startswith('const')]
                                    function_lines = [line.strip() for line in lines if "router." in line or "exports." in line]

                                    if const_lines:
                                        write_to_file("---- Constants:")
                                        for const_line in const_lines:
                                            write_to_file("------ " + const_line)

                                    if function_lines:
                                        write_to_file("---- Functions:")
                                        for function_line in function_lines:
                                            write_to_file("------ " + function_line)

    # Call the function to refactor and generate multiple .txt files
    list_controllers_routes_and_functions_to_folder(directory)

# Define the directory to analyze and output file name
directory_to_analyse = "server/api/controllers"

# Call the function to refactor and generate multiple .txt files
refactor_code_to_generate_multiple_txts(directory_to_analyse)