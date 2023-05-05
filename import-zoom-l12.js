#!/usr/bin/env node

// This script copies project directories from the Zoom L-12 SD card
// into the date-based media directory
// Usage: node import-zoom-l12.js

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

let DIRECTORIES = [
  "/Volumes/L-12_SD/FOLDER02",
  "/Volumes/NO NAME/FOLDER02",
  "/Volumes/L-8_SD/FOLDER02",
  "/Volumes/L-8_SD/PROJECT",
  "/Volumes/H4N_SD/STEREO/FOLDER01",
  "/Volumes/H4N_SD/STEREO/FOLDER02",
];

const rootTargetDir = "/Users/richard/Desktop/msc/media";

// https://stackoverflow.com/a/52338335
function copyFolderSync(from, to) {
  fs.mkdirSync(to);
  fs.readdirSync(from).forEach((element) => {
    if (fs.lstatSync(path.join(from, element)).isFile()) {
      fs.copyFileSync(path.join(from, element), path.join(to, element));
    } else {
      copyFolderSync(path.join(from, element), path.join(to, element));
    }
  });
}

function maybeCopyFile(srcDir, file) {
  let parts = file.match(/(\d\d)(\d\d)(\d\d)_\d+/);
  console.log(file, parts);
  let targetDir = `${rootTargetDir}/20${parts[1]}/20${parts[1]}-${parts[2]}-${parts[3]}`;
  let targetFile = `${targetDir}/${file}`;
  let fullFilePath = `${srcDir}/${file}`;
  if (!fs.existsSync(targetFile)) {
    console.log(`copying ${fullFilePath} -> ${targetFile}`);
    fs.mkdirSync(targetDir, { recursive: true });
    copyFolderSync(fullFilePath, targetFile);
  }
}

function runCopy(srcDir) {
  if (fs.existsSync(srcDir)) {
    console.log(`Checking for files in ${srcDir}`);

    fs.readdir(srcDir, (err, files) => {
      if (!err) files.map((file) => maybeCopyFile(srcDir, file));

      // http://hints.macworld.com/article.php?story=20030307112511721
      console.log("diskutil list external");
      console.log(execSync("diskutil list external", { encoding: "utf8" }));
      console.log("diskutil eject /dev/<name>");
    });
  }
}

if (require.main === module) {
  DIRECTORIES.map(runCopy);
}
