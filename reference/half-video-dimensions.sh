#!/bin/bash

# Note this is mostly for reference. It needs to be run in the same folder

for f in *.MOV; do
  outfile="decimate/${f%.MOV}_half.MOV"
  if [ ! -f "$outfile" ]; then
    ffmpeg -i "$f" -an -vf decimate=2:2 "$outfile"
  else
    echo "Output file $outfile already exists, skipping."
  fi
done