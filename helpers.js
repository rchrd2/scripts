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

/**
 * Run a command synchronously
 */
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
  const check = () => {
    if (!checkRunning(process.ppid)) {
      log("not running");
      process.exit(0);
    } else {
      // I am going crazy, because this only works when
      // There is a log here. If there is no log in the check,
      // it doesn't work
      console.log("running"); // !important!
      setTimeout(check, 1000);
    }
  };
  setTimeout(check, 1000);
};

/**
 * Run a command if the file does not exist
 */
const cFile = (cmd, file) => {
  funcFile(() => c(cmd), file);
};

/**
 * Run a function if the file does not exist
 */
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

const readStdInFromArgs = (stdin) => {
  if (!stdin.isTTY) {
    return fs.readFileSync(stdin.fd, "utf-8").toString().trim().split("\n");
  }
  return [];
};

/**
 * Adds a string of text to the end of a file before the file extension
 */
const appendToFileName = (fileName, append) => {
  let parts = fileName.match(/(\.\w\w\w)$/gi);
  if (parts) {
    return fileName.replace(parts[0], `${append}${parts[0]}`);
  } else {
    return fileName;
  }
};

/**
 * Changes the extension of a given file name string
 */
const changeExtension = (fileName, extension) => {
  let parts = fileName.match(/(\.\w\w\w)$/gi);
  if (parts) {
    return fileName.replace(parts[0], `${extension}`);
  } else {
    return fileName;
  }
};

/**
 * Check if a command is installed and exit if not
 */
const requireCommand = (cmd) => {
  try {
    execSync(`which ${cmd}`, { encoding: "utf8" });
  } catch (error) {
    console.error(`Required command "${cmd}" not found. Please install`);
    process.exit(1);
  }
};

/**
 * Run a function on each file passed in via stdin or command line
 */
const pipeable = (func, inputTypes, requiredCommands) => {
  requiredCommands?.forEach(requireCommand);

  var argv = require("minimist")(process.argv.slice(2));
  [...readStdIn(), ...argv["_"]].forEach((f) => {
    if (
      !inputTypes ||
      inputTypes.length == 0 ||
      inputTypes.some((type) => f.toLowerCase().endsWith(type))
    ) {
      func(f);
    }
  });
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
  readStdInFromArgs,
  appendToFileName,
  changeExtension,
  pipeable,
};

/*
Notes:

log stream --info --debug --predicate 'process == "syslog"'
https://apple.stackexchange.com/questions/70116/how-can-i-debug-an-automator-workflow
*/
