#!/usr/bin/env node

const { log, c, cFile, funcFile, helpersConfig, readStdIn } = require("./helpers.js");

helpersConfig.dryRun = false;

var argv = require("minimist")(process.argv.slice(2));

const validateFile = (f) => {
  return ['.wav', '.mp3', '.png', '.dat'].some((extension) => f.toLowerCase().endsWith(extension));
}

const processFile = (f, index, array) => {
  if (validateFile(f)) {
    c(`scp '${f}' rcaceres@uso.io:sites/net.rchrd.dev/web/transit/uploads`);
  }
}


if (require.main === module) {
  [...readStdIn(), ...argv["_"]].forEach(processFile);
}

/*
Note this is scripted with an auotmator action located
in the folder /Users/richard/Library/Services/
It needs to accept stdin.
*/