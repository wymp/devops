#!/bin/env node
const { existsSync, readFileSync } = require('fs');

// NOTE: Because of the complexities of parsing arguments, this script is more in the style of a bash script than a js
// script. It uses a few unsafe idioms, which you should avoid learning from!

let pkgjson;
let engines;
let available;
let selected = null;

const echoHelp = (out = console.log) => {
  const script = process.argv[1].split(/\//g).pop();
  out(`Usage: ${script} (-f|--file [path-to-package.json]) [ENGINE]`);
  out(`       ${script} -h|--help`);
  out();
  out(`Available Engines: ${
    available
      ? `'${available.join(`', '`)}'`
      : pkgjson
        ? '(Unknown - invalid package.json file)'
        : '(Unknown - try "node" or "pnpm")'
  }`);
  out();
}

const exitWithError = (msg) => {
  echoHelp(console.error);
  console.error(msg);
  process.exit(1);
}

const getEngines = () => {
  if (!pkgjson) {
    exitWithError(
      `E: Programmer error! This shouldn't happen. You might be able to fix it by passing the -f|--file argument.`
    );
  } else if (!existsSync(pkgjson)) {
    exitWithError(`E: '${pkgjson}' doesn't exist. Current working directory is '${process.cwd()}'`);
  }
  engines = JSON.parse(readFileSync(pkgjson, 'utf8')).engines;
  if (!engines) {
    exitWithError(`E: No 'engines' field in '${pkgjson}'`);
  }
  available = Object.keys(engines).sort();
}

for (let i = 2; i < process.argv.length; i++) {
  if (process.argv[i].match(/^-f|--file$/)) {
    pkgjson = process.argv[++i];
    getEngines();
  } else if (process.argv[i].match(/^-h|--help$/)) {
    echoHelp();
    process.exit(0);
  } else {
    if (selected) {
      exitWithError(`E: Unknown argument '${process.argv[i]}'`);
    }
    selected = process.argv[i];
  }
}

if (!pkgjson) {
  pkgjson = `./package.json`;
}

if (!engines) {
  getEngines();
}

if (!selected) {
  exitWithError(`E: No engine selected. Please pass one of the available engines as argument.`);
}

if (!engines[selected]) {
  exitWithError(`E: Unknown engine '${selected}'. Please select one of the available engines.`);
}

process.stdout.write(engines[selected]);
