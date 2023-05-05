#!/usr/bin/env node
/*
Usage:
$ ./half-image-dimensions.js ./my-file.jpg
$ echo ./my-file.jpg | ./half-image-dimensions.js
*/

const {
  cFile,
  helpersConfig,
  appendToFileName,
  pipeable,
} = require("./helpers.js");

helpersConfig.dryRun = false;

if (require.main === module) {
  pipeable(
    (f, index, array) => {
      outFile = appendToFileName(f, "-half");
      cFile(
        // does not work
        // `magick "${f}" -decimate 2 -define preserve-iptc=true -define preserve-jpeg-iptc=true "${outFile}"`,
        // not sure if it's better
        // `magick "${f}" -resize 50% -filter box "${outFile}"`,
        // use default for downsizing
        `magick "${f}" -resize 50% "${outFile}"`,
        outFile
      );
    },
    [".jpg"]
  );
}
