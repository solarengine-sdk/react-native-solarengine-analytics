This directory contains the standalone Harmony demo.

Install dependencies:

```sh
yarn
```

Bundle the JS app for Harmony and start Metro:

```sh
yarn harmony
```

`yarn harmony` also opens `harmonySample` in DevEco Studio so certificates and
device signing can be configured there. If DevEco Studio is installed elsewhere,
set `HARMONY_IDE_PATH` to the `.app` path before running the command.

If you only need to refresh the Harmony Metro host file:

```sh
yarn set-harmony-metro
```
