#!/usr/bin/env node

// WARNING!! This does not do colors properly. Don't use..
// Use Nikon NX GUI program instead

const {
  funcFile,
  c,
  helpersConfig,
  changeExtension,
  pipeable,
} = require("./helpers.js");

helpersConfig.dryRun = false;

if (require.main === module) {
  pipeable(
    (f, index, array) => {
      outFile = changeExtension(f, ".jpg");
      funcFile(() => {
        c(`convert "${f}" -quality 100%  "${outFile}"`);
        c(`exiftool -tagsfromfile "${f}" -all:all "${outFile}"`);
      }, outFile);
    },
    [".nef"],
    ["convert", "exiftool"]
  );
}
