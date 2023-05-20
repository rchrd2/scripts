#!/usr/bin/env node

const { c, helpersConfig, pipeable } = require("../helpers.js");

helpersConfig.dryRun = false;

const uploadUrl = "rcaceres@dev.rchrd.net:sites/net.rchrd.dev/web/transit/";
const allowedExtensions = [
  ".wav",
  ".mp3",
  ".png",
  ".dat",
  ".mov",
  ".jpg",
  ".tif",
  ".aif",
  ".mp4",
  ".nef",
  ".zip",
];

const processFile = (f, index, array) => {
  // c(`scp '${f}' ${uploadUrl}`);
  c(`rsync -vv '${f}' ${uploadUrl}`);
};

if (require.main === module) {
  pipeable(processFile, allowedExtensions);
}

module.exports = {
  processFile,
};

/*
Note this is scripted with an automator action located
in the folder /Users/richard/Library/Services/
*/
