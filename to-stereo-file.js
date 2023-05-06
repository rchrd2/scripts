#!/usr/bin/env node

// Does not work yet...

const {
  pipeable,
  cFile,
  helpersConfig,
  appendToFileName,
} = require("./helpers.js");

helpersConfig.dryRun = false;

let prevFile = null;

const processFile = (f, index, array) => {
  if (prevFile == null) {
    prevFile = f;
  } else {
    let stereoFile = appendToFileName(f, "-stereo");
    let args = ` -filter_complex "[0:a]pan=stereo|c0=c1[a1];[1:a]pan=stereo|c0=c1[a2];[a1][a2]amerge=inputs=2[a]" -map "[a]"`;
    args = `-filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0=c1[left]" -map "[left]" `;
    args = `-filter_complex "[0:a]pan=1c|c0=1[left];[1:a]pan=1c|c0=0[right];[left][right]amerge=inputs=2[a]" -map "[a]"`;
    cFile(
      `ffmpeg -i '${prevFile}' -i '${f}' ${args} '${stereoFile}'`,
      stereoFile
    );
    prevFile = null;
  }
};

if (require.main === module) {
  pipeable(processFile, [".wav"], ["ffmpeg"]);
}
