#!/bin/bash

# Watch .swift files for changes and compile each separately
#find . -name '*.swift' | entr sh -c 'for file in *.swift; do echo swiftc "$file" -o "${file%.swift}"; done'

# echo 'play8.swift' | entr sh -c "xargs | echo swiftc helpers.swift $file"

# find . -name '*.swift' | xargs echo #entr sh -c "xargs | echo "

find . -name '*.swift' | entr sh -c "xargs echo "


# ls hello.sh | entr sh -c 'sh hello.sh {}'
