#!/usr/bin/env node
/*
Usage:
$ ./split-stereo-file.js ./my-file.wav
$ echo ./my-file.wav | ./prepare-audio-for-upload.js
*/

const { cFile, helpersConfig, readStdIn } = require("./helpers.js");

helpersConfig.dryRun = false;

var argv = require("minimist")(process.argv.slice(2));

// TODO make it work with other file types
const INPUT_TYPES = [".wav"];

const processFile = (f, index, array) => {
  if (INPUT_TYPES.some((type) => f.toLowerCase().endsWith(type))) {
    let originalF = f;
    left = f.replace(/\.\w\w\w$/gi, "-left.wav");
    right = f.replace(/\.\w\w\w$/gi, "-right.wav");
    cFile(
      `ffmpeg -i '${originalF}' -map_channel 0.0.0 '${left}' -map_channel 0.0.1 '${right}'`,
      f
    );
  }
};

if (require.main === module) {
  [...readStdIn(), ...argv["_"]].forEach(processFile);
}

/*
Note this is scripted with an automator action located
in the folder /Users/richard/Library/Services/
It needs to accept stdin.

TODOs:
- bug: files with a ' in the name fail
*/
