#!/bin/bash

# chatgpt
# https://chatgpt.com/c/a89b68f0-9104-434e-ade6-4d47426e9169


# Read filenames from stdin into an array, ignoring those with "-combined" in the name
files=()
while IFS= read -r line; do
    if [[ "$line" != *"-combined"* ]]; then
        files+=("$line")
    fi
done

# Ensure there are at least two files
if [ "${#files[@]}" -lt 2 ]; then
    echo "Please provide at least two files, none of which should contain '-combined' in their names."
    exit 1
fi

# Create the input arguments for ffmpeg
input_args=""
filter_complex_args=""
for i in "${!files[@]}"; do
    input_args+="-i '${files[$i]}' "
    filter_complex_args+="[$i:v:0][$i:a:0]"
done

# Generate the filter_complex argument for concat and volume
filter_complex_args+="concat=n=${#files[@]}:v=1:a=1[v][a];[a]volume=0dB[aout]"

# Extract the directory, base name, and extension of the first file
first_file="${files[0]}"
dir_name=$(dirname "$first_file")          # Get directory name
base_name=$(basename "$first_file" .mov)   # Get base name without the .mov extension
extension="${first_file##*.}"              # Extract file extension

# Create the output file name with the same extension as the first file
output_file="${dir_name}/${base_name}-combined.${extension}"

# Run ffmpeg with the constructed arguments
eval "/usr/local/bin/ffmpeg ${input_args} -filter_complex '${filter_complex_args}' -map '[v]' -map '[aout]' '${output_file}'"

echo "Combined video saved as ${output_file}"

