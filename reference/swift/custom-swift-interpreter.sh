#!/bin/bash --norc

# This is a custom Swift interpreter that allows you to write scripts in Swift
# Basically, it just prepends the contents of helpers.swift to your script and
# then runs it with the Swift interpreter.
#
# This allows me to not have to compile my Swift code before execution
#
# The same thing could be done with
# /usr/bin/swift <(cat ./helpers.swift ./hello.swift)
#
# Example Usage:
#
# #!/usr/bin/env custom-swift-interpreter.sh
# name()


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

helpers_path="$script_dir/helpers.swift"
first_line=$(head -n 1 "$command_arg")

if [[ $first_line == "#"* ]]; then
  full_source_code="$(cat "$helpers_path"; tail -n +2 "$command_arg")"
else
  full_source_code="$(cat "$helpers_path")"
fi

swift <(echo "$full_source_code") "$@" <<< "$input_data"
