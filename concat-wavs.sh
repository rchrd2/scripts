#!/bin/bash
# $ find . -name "*.wav" | concat-wavs.sh

export PATH="/usr/local/bin:$PATH"

# Initialize an empty array to store filenames
files=()

# Loop through each file passed via stdin
while IFS= read -r filename; do
    # Add each filename to the array
    files+=("$filename")
done

# Sort the filenames alphabetically
IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
unset IFS

# Initialize an empty string to store the list of input files
input_files=""

# Set the first filename as the template for the output filename
first_filename="${sorted_files[0]}"

# Loop through the sorted filenames to prepare for concatenation
for filename in "${sorted_files[@]}"; do
    # Add each filename to the list of input files, ensuring it's correctly quoted
    input_files+="'$filename' "
done

# Use the first file's name as the base for the output file name
base_name=$(basename "$first_filename" .wav)
dir_name=$(dirname "$first_filename")

# Construct the output filename
output_file="${dir_name}/${base_name}-combined.wav"

# Run through sox to concatenate the files into the output file
eval "sox $input_files '$output_file'"

# Check if sox succeeded
if [ $? -eq 0 ]; then
    echo "Successfully concatenated files into \"$output_file\""
else
    echo "Failed to concatenate files"
fi
