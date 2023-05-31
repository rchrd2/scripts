#!/usr/bin/env node

const path = require("path");

const {
  pipeable,
  cFile,
  helpersConfig,
  appendToFileName,
  log,
} = require("./helpers.js");

helpersConfig.dryRun = false;

let prevFile = null;

const processFile = (f, index, array) => {
  if (prevFile == null) {
    prevFile = f;
  } else {
    // As a heuristic, sort the filenames to decide left and right
    const files = [prevFile, f].sort();
    const file2Basename = path.parse(files[1]).name;
    let stereoFile = appendToFileName(files[0], `__${file2Basename}_ST`);
    log(`left: ${files[0]}\nright: ${files[1]}\nstereo: ${stereoFile}`);
    cFile(
      `sox -M -c 1 '${files[0]}' -c 1 '${files[1]}' '${stereoFile}'`,
      stereoFile
    );
    prevFile = null;
  }
};

if (require.main === module) {
  pipeable(processFile, [".wav"], ["sox"]);
}
