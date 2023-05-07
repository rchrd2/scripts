#!/usr/bin/env node
/*
Usage:
$ ./half-video-dimensions.js ./my-file.mov
$ echo ./my-file.mov | ./half-video-dimensions.js
*/

const {
  cFile,
  helpersConfig,
  appendToFileName,
  pipeable,
} = require("./helpers.js");

helpersConfig.dryRun = false;

if (require.main === module) {
  pipeable((f, index, array) => {
    const outfile = appendToFileName(f, "-half");
    cFile(`ffmpeg -i "${f}" -an -vf decimate=2:2 "${outfile}"`, outfile);
  }, []);
}
