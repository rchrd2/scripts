#!/bin/bash --norc

# A wrapper around the swift executable that includes helpers.swift
# Again, a workaround to compiling my Swift scripts

# Get the directory containing the script
script_dir=$(dirname "$0")

# Read the input from stdin without blocking
if [ -t 0 ]; then
  input_data=""
else
  input_data=$(cat)
fi

# Read the first command-line argument
command_arg="$1"
shift

# if command_arg doesn't exist exit 1
if [ ! -f "$command_arg" ]; then
  echo "File '$command_arg' does not exist."
  exit 1
fi

helpers_path="$script_dir/src/SwiftHelpers/Sources/SwiftHelpers/SwiftHelpers.swift"
first_line=$(head -n 1 "$command_arg")

if [[ $first_line == "#"* ]]; then
  full_source_code="$(cat "$helpers_path"; tail -n +2 "$command_arg")"
else
  full_source_code="$(cat "$helpers_path" "$command_arg")"
fi

/usr/bin/swift <(echo "$full_source_code") "$@" <<< "$input_data"
