#!/usr/bin/env node

/**
 * Script to play multiple audio files at once.
 * Useful for auditioning Zoom L12 recordings without opening a DAW
 *
 * If you pass a list of directories, it will play those in sequence, eg like a playlist
 *
 * Usage example:
 * $ ls /Users/richard/msc/media/2022/2022-04-04/220404_171620/*WAV | node play8.js
 * $ ls -d /Users/richard/msc/media/2022/2022-04-01/* | play8.js
 */

const {
  log,
  c2,
  exitWhenParentProcessExits,
  helpersConfig,
  readStdIn,
} = require("../helpers.js");
const fs = require("fs");

helpersConfig.dryRun = false;

var argv = require("minimist")(process.argv.slice(2));

const playFile = (f, index, array) => {
  if (
    fs.lstatSync(f).isDirectory() ||
    f.endsWith(".ZDT") ||
    f.endsWith("MASTER.WAV") ||
    (!fs.lstatSync(f).isFile() &&
      !f.toLowerCase().endsWith(".wav") &&
      !f.toLowerCase().endsWith(".aiff") &&
      !f.toLowerCase().endsWith(".mp3"))
  ) {
    return;
  }
  const p = new Promise((resolve, reject) => {
    c2(`afplay '${f}'`, resolve, { killOnExit: true });
  });
  return p;
};

const playArray = (files) => {
  log("🔉 Playing new set of files");
  return Promise.all(files.map(playFile));
};

const playAllFiles = (inputFiles) => {
  const files = [];
  const directories = [files];
  inputFiles.forEach((f) => {
    if (fs.lstatSync(f).isDirectory()) {
      f = f.replace(/\/$/, "");
      const dirFiles = fs.readdirSync(f);
      directories.push(dirFiles.map((childF) => `${f}/${childF}`));
    } else if (fs.lstatSync(f).isFile()) {
      files.push(f);
    }
  });

  return directories
    .filter((v) => v.length > 0)
    .map((files) => () => playArray(files))
    .reduce((prev, cur) => {
      return prev.then(cur);
    }, Promise.resolve());
};

if (require.main === module) {
  playAllFiles([...readStdIn(), ...argv["_"]]).then(() => {
    log("You are the weakest link. Goodbye");
    process.exit(0);
  });

  exitWhenParentProcessExits();
}
