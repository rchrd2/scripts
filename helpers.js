const fs = require("fs");
const { exec, execSync } = require("child_process");

const helpersConfig = {
  dryRun: false,
  // How to monitor syslog:
  // $ log stream --info --debug --predicate 'process == "syslog"'
  enableSyslog: true,
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

const c2 = (cmd, onExit = () => {}, { killOnExit = true }) => {
  log(`>>> ${cmd}`);
  if (!helpersConfig.dryRun) {
    const child = exec(cmd, { encoding: "utf8" });
    child.stdout.pipe(process.stdout);
    child.on("exit", onExit);
    if (killOnExit) {
      process.on("exit", () => {
        if (checkRunning(child.pid)) {
          log(`Killing PID ${child.pid}`);
          process.kill(child.pid);
        }
      });
    }
    return child;
  } else {
    log("Dry run so delaying 1 second..");
    setTimeout(onExit, 1000);
  }
};

// Return true if process following pid is running
const checkRunning = (pid) => {
  try {
    return process.kill(pid, 0);
  } catch (error) {
    // console.error(error);
    return error.code === "EPERM";
  }
};

// I found this was necessary when running under Automator in
// order for child process to exit when parent process exits.
const exitWhenParentProcessExits = () => {
  setInterval(() => {
    if (checkRunning(process.ppid)) {
      // log("running");
    } else {
      // log("not running");
      process.exit(0);
    }
  }, 1000);
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

module.exports = {
  log,
  c,
  c2,
  checkRunning,
  exitWhenParentProcessExits,
  cFile,
  funcFile,
  helpersConfig,
  readStdIn,
};

/*
Notes:

log stream --info --debug --predicate 'process == "syslog"'
https://apple.stackexchange.com/questions/70116/how-can-i-debug-an-automator-workflow
*/
