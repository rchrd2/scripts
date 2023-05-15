// I asked chatGPT to convert this to JavaScript.
// I still need to test this/use my helper functions.

const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const {
  cFile,
  helpersConfig,
  appendToFileName,
  pipeable,
  log,
} = require("./helpers.js");

helpersConfig.dryRun = false;
helpersConfig.enableSyslog = true;

const BASE = "/Users/richard/Desktop/msc/media";

function archive(base, f) {
  log(f);
  if (!fs.existsSync(base) || !fs.statSync(base).isDirectory()) {
    log("Missing base");
    return;
  }

  if (!fs.existsSync(f)) return;

  const date = new Date(fs.statSync(f).mtime).toISOString().slice(0, 10);
  const year = date.slice(0, 4);
  const targetDir = path.join(base, year, date);

  log(`Copying ${f} to ${targetDir}`);
  return;

  fs.mkdirSync(targetDir, { recursive: true });

  const cp = spawn("cp", ["-riv", "-n", f, targetDir + "/"]);

  cp.stdout.on("data", (data) => {
    log(data.toString());
  });

  cp.stderr.on("data", (data) => {
    console.error(data.toString());
  });

  cp.on("close", (code) => {
    if (code !== 0) {
      console.error(`cp process exited with code ${code}`);
    }
  });
}

if (require.main === module) {
  process.stdin.setEncoding("utf8");
  pipeable((f, index, array) => {
    archive(BASE, f);
  }, []);
}
