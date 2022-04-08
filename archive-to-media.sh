#!/bin/bash

# Archiving to media Utils
# $ yes n | archive ~/Desktop/msc/media $(ls)
archive() {
    if [ ! -d "$1" ]; then echo Missing base; return 1; fi
    local BASE=$1
    for f in "${@:2:$#-1}"; do
        if [ -d "$f" ]; then continue; fi;
        local DATE=`date -r "${f}" "+%Y-%m-%d"`
        local YEAR=`date -r "${f}" "+%Y"`
        local TARGET_DIR="$BASE/$YEAR/$DATE"
        mkdir -p "${TARGET_DIR}"
        echo cp -iv "${f}" "${TARGET_DIR}/"
        cp -iv "$f" "${TARGET_DIR}/"
    done
}

BASE='/Users/richard/Desktop/msc/media'

while read line
do
  echo $line
  archive $BASE "${line}"
done < "${1:-/dev/stdin}"