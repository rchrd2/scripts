#!/bin/sh

# See http://eradman.com/entrproject/

for input in $(ls *.swift); do
  output="build/$(basename $input .swift)"

  # if the name is helpers.swift skip
  [[ $input == "helpers.swift" ]] && continue

  [[ $input -nt $output ]] && {
      (set -x; swiftc helpers.swift $input > $output)
  }
done