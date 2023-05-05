#!/usr/bin/env node

const { c, helpersConfig, pipeable } = require("./helpers.js");

const {
  processFile: prepareAudioForUpload,
} = require("./prepare-audio-for-upload.js");

helpersConfig.dryRun = false;

const uploadUrl =
  "rcaceres@dev.rchrd.net:sites/net.rchrd.dev/web/transit/uploads";

const processFile = (f, index, array) => {
  if (f.toLowerCase().endsWith(".mp3")) {
    // Convenience for converting and uploading mp3s
    prepareAudioForUpload(f);
    c(`scp '${f}' ${uploadUrl}`);
    c(`scp '${f}.dat' ${uploadUrl}`);
  } else if (f.toLowerCase().endsWith(".wav")) {
    prepareAudioForUpload(f);
    c(`scp '${f}.mp3' ${uploadUrl}`);
    c(`scp '${f}.dat' ${uploadUrl}`);
  } else {
    c(`scp '${f}' ${uploadUrl}`);
  }
};

if (require.main === module) {
  pipeable(processFile, [".wav", ".mp3", ".png", ".dat"]);
}

module.exports = {
  processFile,
};

/*
Note this is scripted with an automator action located
in the folder /Users/richard/Library/Services/
*/
