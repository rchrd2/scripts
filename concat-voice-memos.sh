#!/bin/bash
# This script doesn't seem to work right now.
# For now use convert-to-wav.sh + concat-wavs.sh instead

# Full path to ffmpeg
FFMPEG="/usr/local/bin/ffmpeg"

# Create temporary files for processing
sorted_file=$(mktemp /tmp/sorted_file.XXXXXX)
temp_dir=$(mktemp -d /tmp/concat_temp.XXXXXX)

# Function to clean up on exit
cleanup() {
  # Remove temporary files
  rm -f "$sorted_file"
  rm -rf "$temp_dir"
}

# Ensure cleanup on exit or interrupt
trap cleanup EXIT

# Ensure there is input coming from stdin
if [ -p /dev/stdin ]; then
  # Read input filenames from stdin, sort them, and format for ffmpeg
  while IFS= read -r file; do
    # Check if file exists
    if [ -f "$file" ]; then
      reencoded_file="$temp_dir/$(basename "$file" .m4a)-reencoded.m4a"
      "$FFMPEG" -i "$file" -c:a aac -b:a 256k "$reencoded_file"
      echo "file '$reencoded_file'" >> "$sorted_file"
    else
      echo "File not found: $file" >&2
    fi
  done
else
  echo "No input received from stdin." >&2
  exit 1
fi

# Check if any valid files were processed
if [ ! -s "$sorted_file" ]; then
  echo "No valid input files processed."
  exit 1
fi

# Extract the first re-encoded filename from the sorted list
first_reencoded_file=$(head -n 1 "$sorted_file" | awk -F"'" '{print $2}')

# Check if any re-encoded file exists
if [ -z "$first_reencoded_file" ]; then
  echo "Error: No re-encoded files found."
  exit 1
fi

# Derive output filename from the first input filename
output_dir=$(dirname "$file")
output_file="${output_dir}/$(basename "${first_reencoded_file%.*}")-output.m4a"

# Run ffmpeg to concatenate files
"$FFMPEG" -f concat -safe 0 -i "$sorted_file" -c copy "$output_file" &
ffmpeg_pid=$!

# Wait for ffmpeg to finish
wait "$ffmpeg_pid"

echo "Files concatenated into $output_file"
