#!/usr/bin/env node

// This does not work yet. turns out decimate removes every other frame, not every other pixel

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

// > "/Users/richard/Library/Application Support/Adapter/ffmpeg" '-i' '/Volumes/Storage_4TB_1/101_0101/MVI_0032.MP4' '-filter_complex' 'scale=1920:trunc(ow/a/2)*2' '-vcodec' 'mpeg4' '-b:v' '150609k' '-qscale:v' '2' '-acodec' 'aac' '-ac' '2' '-async' '1' '-strict' 'experimental' '/Volumes/Storage_4TB_1/101_0101/MVI_0032(2).mp4' '-threads' '0'
