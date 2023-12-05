#!/usr/bin/env node

// Script that takes a list of lines from the clipboard and sums up the hours
// in the lines.
// Richard-specific script for the way I keep track of hours on projects.

// Usage: pbpaste | hours.js

const fs = require("fs");

const text = fs.readFileSync("/dev/stdin", "utf-8");
let totalHours = 0;

const lines = text.split("\n");
lines.forEach((line) => {
  // regular expression to find X hours
  const regex = /(\-?\d?\d?\d?\.?\d?\d?)?\s*hours?/g;
  const matches = line.match(regex);

  if (matches) {
    console.log(line);
    for (const match of matches) {
      const numericPart = parseFloat(match);
      if (!isNaN(numericPart)) {
        // console.log(numericPart);
        totalHours += numericPart;
      }
    }
  }
});

console.log("Total hours:", totalHours);
