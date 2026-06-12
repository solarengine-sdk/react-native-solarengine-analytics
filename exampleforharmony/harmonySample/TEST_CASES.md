# RN Harmony Test Cases

## Scope

This document covers automated and manual verification for the Harmony sample in `exampleforharmony/harmonySample`.

## Automated Cases (Hypium)

File: `entry/src/test/LocalUnit.test.ets`

1. `should expose stable log prefix constant`
- Verify bridge log prefix remains `[SeSDKRNBridge]:` to avoid log parsing regressions.

2. `should compute multiply result in bridge module`
- Verify `SolarengineAnalysisReactNative.multiply(6, 7)` returns `42`.
- Verify module name remains `SolarengineAnalysisReactNative`.

3. `should create turbo module factory and resolve module by name`
- Verify `SolarEnginePackage` factory reports registered module as available.
- Verify unknown module name returns unavailable.
- Verify registered module can be created and unknown module returns `null`.

File: `entry/src/ohosTest/ets/test/SolarEngineBridge.test.ets`

4. `should keep bridge log prefix stable`
- Verify runtime bridge prefix remains `[SeSDKRNBridge]:`.

5. `should support multiply smoke test`
- Verify bridge module can be constructed in test runtime.
- Verify `multiply(3, 9)` returns `27`.

## Manual Cases (Device/Emulator)

1. Bridge initialization path
- Launch app and ensure no crash when bridge loads.
- Confirm log output contains the bridge prefix and init messages.

2. SDK pre-init path
- Trigger `preInit(appkey)` from JS layer.
- Confirm no native exception in logs.

3. Attribution/deeplink callback registration
- Register callbacks from JS.
- Verify callback function can be invoked without crash.

## How To Run

## Full RN + Harmony Flow

1. Install Harmony demo dependencies:

```bash
cd exampleforharmony
yarn
```

2. Prepare the Harmony bundle and Metro config:

```bash
cd exampleforharmony
yarn set-harmony-metro
yarn bundle:harmony
```

3. Start Harmony Metro:

```bash
cd exampleforharmony
yarn start
```

4. Log viewing (SDK call logs will show with tag `SeSDKRN`):

```bash
hdc shell hilog | egrep "SeSDKRN|testTag|OHOS_REPORT"
```

If `hvigorw` is available in your Harmony environment:

```bash
cd exampleforharmony/harmonySample
hvigorw --mode module -p module=entry@default -p product=default -p buildMode=debug test
```

For ohosTest suite:

```bash
cd exampleforharmony/harmonySample
hvigorw --mode module -p module=entry@ohosTest -p product=default -p buildMode=debug test
```

For a one-command local bundle + Metro flow:

```bash
cd exampleforharmony
yarn harmony
```
