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
    let stereoFile = appendToFileName(files[0], `--${file2Basename}-stereo`);
    log(`left: ${files[0]}\nright: ${files[1]}\nstereo: ${stereoFile}`);
    cFile(
      `sox '${files[0]}' '${files[1]}' '${stereoFile}' channels 2`,
      stereoFile
    );
    prevFile = null;
  }
};

if (require.main === module) {
  pipeable(processFile, [".wav"], ["sox"]);
}
