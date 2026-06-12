#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const exampleDir = path.resolve(__dirname, '..');
const harmonySampleDir = path.join(exampleDir, 'harmonySample');
const harmonyMetroConfigPath = path.join(
  harmonySampleDir,
  'entry',
  'src',
  'main',
  'ets',
  'pages',
  'HarmonyMetroConfig.ets'
);
const DEFAULT_METRO_PORT = 8081;
const action = process.argv[2];
const actionArgs = process.argv.slice(3);

function fail(message) {
  console.error(`\n[harmony-platform] ${message}\n`);
  process.exit(1);
}

function usage() {
  return [
    'Usage:',
    '  node scripts/harmony-platform.js set-metro [port]',
    '  node scripts/harmony-platform.js set-bundle',
    '  node scripts/harmony-platform.js bundle',
    '  node scripts/harmony-platform.js metro',
    '  node scripts/harmony-platform.js run',
  ].join('\n');
}

function commandExists(command) {
  return spawnSync('which', [command], { stdio: 'ignore' }).status === 0;
}

function commandSucceeds(command, args, options = {}) {
  return (
    spawnSync(command, args, {
      cwd: options.cwd,
      stdio: 'ignore',
      shell: false,
    }).status === 0
  );
}

function runCommand(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd,
    stdio: 'inherit',
    shell: false,
  });

  if (result.status !== 0) {
    throw new Error(
      `${command} ${args.join(' ')} failed with exit code ${result.status || 1}`
    );
  }
}

function firstIpv4Address(preferredInterfaces) {
  const interfaces = os.networkInterfaces();
  const candidates = [];

  for (const [name, records] of Object.entries(interfaces)) {
    if (!records) {
      continue;
    }

    for (const record of records) {
      if (record.family === 'IPv4' && !record.internal) {
        candidates.push({ name, address: record.address });
      }
    }
  }

  for (const name of preferredInterfaces) {
    const match = candidates.find((item) => item.name === name);
    if (match) {
      return match.address;
    }
  }

  return candidates[0] ? candidates[0].address : null;
}

function setHarmonyMetroHost(portOverride) {
  const host =
    (process.env.HM_METRO_HOST || '').trim() ||
    firstIpv4Address(['en0', 'en1', 'bridge100']) ||
    '127.0.0.1';
  const rawPort = Number.parseInt(
    String(portOverride || process.env.RCT_METRO_PORT || ''),
    10
  );
  const port = Number.isFinite(rawPort) ? rawPort : DEFAULT_METRO_PORT;
  const content = `export const HARMONY_METRO_HOST: string = '${host}';
export const HARMONY_METRO_PORT: number = ${port};
export const HARMONY_METRO_ENABLED: boolean = true;
`;

  fs.writeFileSync(harmonyMetroConfigPath, content, 'utf8');
  console.log(`[harmony-metro] host=${host} port=${port}`);
  console.log(`[harmony-metro] config -> ${harmonyMetroConfigPath}`);

  if (host === '127.0.0.1') {
    console.warn(
      '[harmony-metro] Could not detect a LAN IP automatically. Set HM_METRO_HOST before running on a device.'
    );
  }

  return port;
}

function setHarmonyBundleMode() {
  const content = `export const HARMONY_METRO_HOST: string = '127.0.0.1';
export const HARMONY_METRO_PORT: number = ${DEFAULT_METRO_PORT};
export const HARMONY_METRO_ENABLED: boolean = false;
`;

  fs.writeFileSync(harmonyMetroConfigPath, content, 'utf8');
  console.log(`[harmony-bundle] config -> ${harmonyMetroConfigPath}`);
}

function metroStatusUrl(port) {
  return `http://127.0.0.1:${port}/status`;
}

function isPortInUse(port) {
  return commandExists('lsof')
    ? commandSucceeds('lsof', [`-iTCP:${port}`, '-sTCP:LISTEN'])
    : false;
}

function isMetroResponding(port) {
  return commandSucceeds('curl', [
    '--silent',
    '--fail',
    '--max-time',
    '2',
    metroStatusUrl(port),
  ]);
}

function isHarmonyMetro(port) {
  const result = spawnSync(
    'curl',
    [
      '--silent',
      '--fail',
      '--max-time',
      '8',
      `http://127.0.0.1:${port}/index.bundle?platform=harmony&dev=true&minify=false&entry-file=index.js`,
    ],
    {
      encoding: 'utf8',
      maxBuffer: 400000,
      shell: false,
    }
  );
  const sample = result.stdout || '';

  return sample.includes(
    'node_modules/@react-native-oh/react-native-harmony/index.js'
  );
}

function findAvailablePort(startPort) {
  for (let port = startPort + 1; port <= startPort + 20; port += 1) {
    if (!isPortInUse(port)) {
      return port;
    }
  }

  return null;
}

function runHarmonyMetro() {
  let port = Number.parseInt(process.env.RCT_METRO_PORT || '', 10);
  if (!Number.isFinite(port)) {
    port = DEFAULT_METRO_PORT;
  }

  if (isPortInUse(port)) {
    if (isMetroResponding(port) && isHarmonyMetro(port)) {
      console.log(
        `[hm] Harmony Metro already responding on port ${port}; reusing existing server.`
      );
      return;
    }

    const nextPort = findAvailablePort(port);
    if (!nextPort) {
      fail(`[hm] Could not find an available fallback port near ${port}.`);
    }
    port = nextPort;
  }

  setHarmonyMetroHost(port);
  runCommand(
    'react-native',
    ['start', '--config', 'metro.config.js', '--port', String(port)],
    {
      cwd: exampleDir,
    }
  );
}

function main() {
  try {
    if (action === 'set-metro') {
      setHarmonyMetroHost(actionArgs[0]);
      return;
    }

    if (action === 'set-bundle') {
      setHarmonyBundleMode();
      return;
    }

    if (action === 'bundle') {
      runCommand('yarn', ['bundle:harmony'], { cwd: exampleDir });
      return;
    }

    if (action === 'metro') {
      runHarmonyMetro();
      return;
    }

    if (action === 'run') {
      setHarmonyMetroHost();
      runCommand('yarn', ['bundle:harmony'], { cwd: exampleDir });
      runHarmonyMetro();
      return;
    }
  } catch (error) {
    fail(error instanceof Error ? error.message : String(error));
  }

  fail(usage());
}

main();
