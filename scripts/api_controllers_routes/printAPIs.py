import os

def list_controllers_routes_and_functions_to_file(directory, output_file):
    with open(output_file, 'w', encoding='utf-8') as out_file:
        # Function to write to the file
        def write_to_file(content):
            print(content, file=out_file)

        # Print the title
        write_to_file("List of Routes and Controllers")

        for root, dirs, files in os.walk(directory):
            controller_files = [f for f in files if f.endswith('Controller.js')]
            if controller_files:
                write_to_file("\nFolder: " + os.path.relpath(root, directory).replace('\\', '/'))

                for controller_file in controller_files:
                    write_to_file("---- File: " + controller_file)

                    with open(os.path.join(root, controller_file), 'r', encoding='utf-8') as file:
                        lines = file.readlines()
                        # Search for lines that contain either "router." or "exports."
                        relevant_lines = [line.strip() for line in lines if "router." in line or "exports." in line]

                        if relevant_lines:
                            for relevant_line in relevant_lines:
                                write_to_file("-------- Relevant line: " + relevant_line)

# Define the directory to analyze and output file name
directory_to_analyse = "server/api/controllers"
output_file_name = "scripts/api_controllers_routes/controllers_and_routes_summary.txt"

# Call the function with the directory of the controllers and the output file path
list_controllers_routes_and_functions_to_file(directory_to_analyse, output_file_name)