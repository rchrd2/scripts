#!/usr/bin/env node

/**
 * Script to play multiple audio files at once.
 * Useful for auditioning Zoom L12 recordings without opening a DAW
 * Usage example:
 * $ ls /Users/richard/Desktop/msc/media/2022/2022-04-04/220404_171620/*WAV | node play8.js
 */

const { log, c, c2, helpersConfig, readStdIn } = require("./helpers.js");

helpersConfig.dryRun = false;

var argv = require("minimist")(process.argv.slice(2));

const processFile = (f, index, array) => {
  if (f.endsWith(".ZDT")) {
    return;
  }
  const p = new Promise((resolve, reject) => {
    c2(`afplay '${f}'`, () => {
      log("On exit");
      resolve();
    });
  });
  return p;
};

if (require.main === module) {
  Promise.all([...readStdIn(), ...argv["_"]].map(processFile)).then(() => {
    log("You are the weakest link. Goodbye");
    process.exit(0);
  });
}
