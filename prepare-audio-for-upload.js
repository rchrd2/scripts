#!/usr/bin/env node
/*
Usage:
$ ./prepare-audio-for-upload.js ./my-file.wav
$ echo ./my-file.wav | ./prepare-audio-for-upload.js
*/

const { cFile, helpersConfig, readStdIn } = require("./helpers.js");

helpersConfig.dryRun = false;

var argv = require("minimist")(process.argv.slice(2));

const INPUT_TYPES = [".wav", ".aif", ".m4a"];

const processFile = (f, index, array) => {
  if (INPUT_TYPES.some((type) => f.toLowerCase().endsWith(type))) {
    let originalF = f;
    f = f.replace(/\.\w\w\w$/gi, ".mp3");
    cFile(`ffmpeg -i '${originalF}' -ab "320k" '${f}'`, f);
  }
  cFile(`audiowaveform -i '${f}' -o '${f}.dat' -z 256 -b 8`, `${f}.dat`);
  cFile(
    `audiowaveform -i '${f}' -o '${f}.png' --zoom=auto -w 1000 -h 300`,
    `${f}.png`
  );
};

if (require.main === module) {
  [...readStdIn(), ...argv["_"]].forEach(processFile);
}

/*
Note this is scripted with an auotmator action located
in the folder /Users/richard/Library/Services/
It needs to accept stdin.
*/
