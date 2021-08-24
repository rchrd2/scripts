const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const helpersConfig = {
  dryRun: false,
  enableSyslog: true,
  // log stream --info --debug --predicate 'process == "syslog"'
  enableConsoleLog: true,
};

const log = (v) => {
  helpersConfig.enableSyslog &&
    execSync(`syslog -s -l i "${v}"`, { encoding: "utf8" });
  helpersConfig.enableConsoleLog && console.log(v);
};

const c = (cmd) => {
  log(`>>> ${cmd}`);
  if (!helpersConfig.dryRun) {
    log(execSync(cmd, { encoding: "utf8" }));
  }
};

const cFile = (cmd, file) => {
  funcFile(() => c(cmd), file);
};

const funcFile = (func, file) => {
  if (!fs.existsSync(file)) {
    func();
  }
  log(file);
};

const readStdIn = () => {
  if (!process.stdin.isTTY) {
    return fs.readFileSync("/dev/stdin").toString().trim().split("\n");
  }
  return [];
};

// const processFile = ()

module.exports = { log, c, cFile, funcFile, helpersConfig, readStdIn };


/*
Notes:

log stream --info --debug --predicate 'process == "syslog"'
https://apple.stackexchange.com/questions/70116/how-can-i-debug-an-automator-workflow
*/
