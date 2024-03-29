#!/usr/bin/env node
/*
Usage:
$ ./prepare-audio-for-upload.js ./my-file.wav
$ echo ./my-file.wav | ./prepare-audio-for-upload.js
*/

const { cFile, helpersConfig, readStdIn, pipeable } = require("./helpers.js");

helpersConfig.dryRun = false;

// Set to true to create mp3 if it's not an mp3
const createMp3 = true;

const processFile = (f, index, array) => {
  let originalF = f;
  cFile(`audiowaveform -i '${f}' -o '${f}.dat' -z 256 -b 8`, `${f}.dat`);
  if (createMp3 && !f.endsWith(".mp3")) {
    f = f.replace(/\.\w\w\w$/gi, ".mp3");
    cFile(`ffmpeg -i '${originalF}' -ab "320k" '${f}'`, f);
    cFile(`audiowaveform -i '${f}' -o '${f}.dat' -z 256 -b 8`, `${f}.dat`);
  }
  // cFile(
  //   `audiowaveform -i '${f}' -o '${f}.png' --zoom=auto -w 1000 -h 300`,
  //   `${f}.png`
  // );
};

if (require.main === module) {
  pipeable(
    processFile,
    [".wav", ".mp3", ".aif", ".mp4", ".m4a"],
    ["ffmpeg", "audiowaveform"]
  );
}

module.exports = {
  processFile,
};

/*
Note this is scripted with an automator action located
in the folder /Users/richard/Library/Services/

TODOs:
- bug: files with a ' in the name fail
*/
