#!/bin/bash
# Usage:
# echo echo '/private/var/folders/wl/scmb9msd3nn69p0d277xsw4c0000gn/T/com.apple.VoiceMemos/.com.apple.uikit.itemprovider.temporary.BptCxO/Monk Ensemble - Oct 17, 2022.m4a' | archive-to-media.sh
#
# TODO
# - make it work with args
# - wire it up to script


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
        echo cp -iv -n "${f}" "${TARGET_DIR}/"
        cp -iv -n "$f" "${TARGET_DIR}/" || true
    done
}

BASE='/Users/richard/Desktop/msc/media'

while read line
do
  echo $line
  archive $BASE "${line}"
done < "${1:-/dev/stdin}"