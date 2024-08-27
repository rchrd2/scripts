#!/bin/bash
# find . -name "*.m4a" | convert-to-wav.sh

export PATH="/usr/local/bin:$PATH"

# Loop through each file passed via stdin
while IFS= read -r filename; do
    # Remove leading/trailing whitespace (if any) from the filename
    trimmed_filename=$(echo "$filename" | xargs)

    # Debug print to see the exact filename being processed
    echo "Working on \"$trimmed_filename\""

    # Get the base name of the file without the directory and extension
    base_name=$(basename "$trimmed_filename")
    dir_name=$(dirname "$trimmed_filename")

    # Construct the output filename with ".wav" appended
    output_file="${dir_name}/${base_name}.wav"

    echo "Output file: $output_file"

    # Convert the file to WAV format with a sample rate of 44.1 kHz
    ffmpeg -nostdin -i "$trimmed_filename" -ar 44100 "$output_file"

    # Check if ffmpeg succeeded
    if [ $? -eq 0 ]; then
        echo "Converted \"$trimmed_filename\" to \"$output_file\" with 44.1 kHz sample rate"
    else
        echo "Failed to convert \"$trimmed_filename\""
    fi
done
