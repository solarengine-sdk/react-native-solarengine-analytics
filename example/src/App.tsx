import React, { useEffect, useRef } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
  Platform,
  ScrollView,
  SafeAreaView,
  StatusBar,
  useColorScheme,
  Linking,
} from 'react-native';
import sdkPackage from '../../package.json';

import * as SolarEngine from 'solarengine-analysis-react-native';
import type {
  RemoteConfig,
  se_initial_config,
  deeplink,
  deferredDeeplink,
  attribution,
  SolarEngineInitiateOptions,
  InitiateCompletionInfo,
  ConfigItem,
} from 'solarengine-analysis-react-native';

import {
  SEUserDeleteType,
  RemoteConfigMergeType,
  PresetEventType,
  AdType,
  SKAdNetworkCoarseType,
  SEIAPStatus,
  Paypal,
} from 'solarengine-analysis-react-native';

// Demo AppKeys from the V4 separated attribution requirements.
const AndroidAppKey = 'd81f85a878ff54b0'; // CN
const iOSAppKey = '7b2a992e08ca8800'; // CN (also temporarily used by VG)
const HMAppKey = '16e503718a7305f5'; // current Harmony test environment

const LOG_PREFIX = '[SeSDK Demo]';
let logSeq = 0;
type IosAutoRunState = { started: boolean; completed: boolean };

const getIosAutoRunState = (): IosAutoRunState => {
  const globalState = globalThis as typeof globalThis & {
    __solarEngineIosAutoRunState?: IosAutoRunState;
  };
  globalState.__solarEngineIosAutoRunState ??= {
    started: false,
    completed: false,
  };
  return globalState.__solarEngineIosAutoRunState;
};

const nextLogSeq = () => {
  logSeq += 1;
  return logSeq;
};

const log = (str: string) => {
  const stamp = new Date().toISOString();
  console.log(`${LOG_PREFIX}[${Platform.OS}][${stamp}] ${str}`);
};

const safeStringify = (value: unknown) => {
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
};

const logCall = (name: string, payload?: unknown) => {
  const seq = nextLogSeq();
  const detail = payload === undefined ? '' : ` ${safeStringify(payload)}`;
  log(`[CALL#${seq}] ${name}${detail}`);
  return seq;
};

const logKeyValues = (prefix: string, value: unknown) => {
  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      logKeyValues(`${prefix}[${index}]`, item);
    });
    return;
  }

  if (value && typeof value === 'object') {
    Object.entries(value as Record<string, unknown>).forEach(([key, item]) => {
      logKeyValues(`${prefix}.${key}`, item);
    });
    return;
  }

  log(`${prefix} = ${String(value)}`);
};

const DEFAULT_RC_KEYS = [
  'key_string',
  'key_number',
  'key_boolean',
  'key_object',
] as const;

// Manual yarn ios/android commands only launch the Demo; test cases run by user action.
const IOS_AUTO_RUN_CASES = false;
const IOS_AUTO_RUN_ALL_FALSE_ONLY = false;

const INITIALIZE_CASES = [
  { name: 'allEnabled', title: 'Initialize (all enabled)', enabled: true },
  { name: 'allDisabled', title: 'Initialize (all disabled)', enabled: false },
] as const;

const delay = (ms: number) =>
  new Promise<void>((resolve) => {
    setTimeout(resolve, ms);
  });

const withCallId = (
  props: Record<string, unknown> | undefined,
  _callId?: number
) => {
  return props ?? {};
};

const PRESET_EVENT_PROPERTIES = { PresetEvent: 'test' };
const PRESET_EVENT_ALL = (PresetEventType.INSTALL |
  PresetEventType.START |
  PresetEventType.END) as PresetEventType;
const getSdkPresetEventTypes = (eventType: PresetEventType) => {
  switch (eventType) {
    case PresetEventType.INSTALL:
      return [0];
    case PresetEventType.START:
      return [1];
    case PresetEventType.END:
      return [2];
    case PRESET_EVENT_ALL:
      return [3];
    default:
      return [];
  }
};
const PRESET_EVENT_CASES = [
  {
    name: 'APP_INSTALL',
    eventType: PresetEventType.INSTALL,
    eventTypeName: 'APP_INSTALL',
    sdkEventTypes: [0],
    props: PRESET_EVENT_PROPERTIES,
  },
  {
    name: 'APP_START',
    eventType: PresetEventType.START,
    eventTypeName: 'APP_START',
    sdkEventTypes: [1],
    props: PRESET_EVENT_PROPERTIES,
  },
  {
    name: 'APP_END',
    eventType: PresetEventType.END,
    eventTypeName: 'APP_END',
    sdkEventTypes: [2],
    props: PRESET_EVENT_PROPERTIES,
  },
  {
    name: 'ALL',
    eventType: PRESET_EVENT_ALL,
    eventTypeName: 'ALL',
    sdkEventTypes: [3],
    props: PRESET_EVENT_PROPERTIES,
  },
] as const;

const trackVerifyEvent = (eventName: string, callId: number) => {
  SolarEngine.trackCustomEvent(
    eventName,
    withCallId({}, callId),
    {
      _currency_type: 'USD',
      _pay_amount: 1,
    },
    '验证事件别名'
  ); // eventAlias
};

function buildInitialConfigSwitches(enabled: boolean) {
  return {
    enable2G: enabled,
    enableAnalytics: enabled,
    enableAttribution: enabled,
    enableSeparatedAttribution: enabled,
    enableAAID: enabled,
    enableCoppa: enabled,
    enableDebug: enabled,
    enableDeferredDeeplink: enabled,
    enableDensity: enabled,
    enableGDPR: enabled,
    enableIPV6: enabled,
    enableKidsApp: enabled,
    enableLanguage: enabled,
    enableLocale: enabled,
    enableLog: true,
    enableNetworkType: enabled,
    enableOAID: enabled,
    enableODID: enabled,
    enableScreenWH: enabled,
    enableTimeZone: enabled,
    enableUA: enabled,
    enableUserData: enabled,
  };
}

function buildInitialConfig(enabled = true): se_initial_config {
  return {
    ...buildInitialConfigSwitches(enabled),

    android: {
      enablePersonalizedAd: enabled,
      isImeiEnabled: false, // demo: disable IMEI collection
      isAndroidIDEnabled: enabled,
      supportMultiProcess: false,
      withDisableOAIDRetry: false,
      withDisableGAIDRetry: false,
    },
    ios: {
      attAuthorizationWaitingInterval: 60,
      caid: '[{"version":"20220111","caid":"912ec803b2ce49e4a541068d495ab570"}]',
      enableODMInfo: false, // overseas SDK only
    },
    harmony: {
      authorizationTimeout: 100,
    },
  };
}

// Minimal config: only enableLog. All other fields unset → SDK uses its own defaults (collection switches default true).
function buildInitialConfigMinimal(): se_initial_config {
  return { enableLog: true };
}

function buildRemoteConfig(): RemoteConfig {
  return {
    enabled: true,
    mergeType: RemoteConfigMergeType.User,
    customIDProperties: { name: 'name_value' },
    customIDEventProperties: { age: 28 },
    customIDUserProperties: { key: 'value' },
  };
}

const handleAttribution: attribution = (code, attributionInfo) => {
  log('Attribution callback code: ' + code);
  log('Attribution callback data: ' + safeStringify(attributionInfo ?? null));
  if (attributionInfo) {
    logKeyValues('Attribution callback', attributionInfo);
  }
};

const handleUAAttribution: attribution = (code, attributionInfo) => {
  log(
    'UA Attribution: code=' +
      code +
      ', payload=' +
      safeStringify(attributionInfo ?? null)
  );
};

const handleREAttribution: attribution = (code, attributionInfo) => {
  log(
    'RE Attribution: code=' +
      code +
      ', payload=' +
      safeStringify(attributionInfo ?? null)
  );
};

const handleDeepLink: deeplink = (code, deepLinkInfo) => {
  log('DeepLink callback code: ' + code);
  log('DeepLink callback data: ' + safeStringify(deepLinkInfo ?? null));
  if (deepLinkInfo) {
    logKeyValues('DeepLink callback', deepLinkInfo);
  }
};

const handleDeferredDeeplink: deferredDeeplink = (
  code,
  deferredDeepLinkInfo
) => {
  log('DeferredDeepLink callback code: ' + code);
  log(
    'DeferredDeepLink callback data: ' +
      safeStringify(deferredDeepLinkInfo ?? null)
  );
  if (deferredDeepLinkInfo) {
    logKeyValues('DeferredDeepLink callback', deferredDeepLinkInfo);
  }
};

const Section = ({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) => (
  <View style={styles.section}>
    <Text style={styles.sectionTitle}>{title}</Text>
    <View style={styles.buttonGrid}>{children}</View>
  </View>
);

const DemoButton = ({
  title,
  onPress,
  color = '#2196F3',
}: {
  title: string;
  onPress: () => void;
  color?: string;
}) => (
  <View style={styles.buttonWrapper}>
    <Button title={title} onPress={onPress} color={color} />
  </View>
);

export default function App() {
  const isDarkMode = useColorScheme() === 'dark';
  const platformDemoLabel =
    Platform.OS === 'ios'
      ? '当前平台 Demo: iOS'
      : Platform.OS === 'android'
        ? '当前平台 Demo: Android'
        : '当前平台 Demo: Harmony';
  const sdkVersionLabel = `SDK 版本: v${sdkPackage.version}`;

  useEffect(() => {
    const initUrl = async () => {
      const url = await Linking.getInitialURL();
      if (url) {
        log('Initial Deeplink URL: ' + url);
        logCall('appDeeplinkOpenURL', { url });
        SolarEngine.appDeeplinkOpenURL(url);
      }
    };
    initUrl();

    const listener = Linking.addEventListener('url', (evt) => {
      if (evt.url) {
        log('Runtime Deeplink URL: ' + evt.url);
        logCall('appDeeplinkOpenURL', { url: evt.url });
        SolarEngine.appDeeplinkOpenURL(evt.url);
      }
    });

    return () => {
      listener.remove();
    };
  }, []);

  const _preInit = () => {
    log('preInit');
    if (Platform.OS !== 'ios' && Platform.OS !== 'android') {
      logCall('setInternalLogEnabled', {
        enabled: true,
        scene: 'before preInit',
      });
      SolarEngine.setInternalLogEnabled(true);
    }
    const appKey =
      Platform.OS === 'ios'
        ? iOSAppKey
        : Platform.OS === 'android'
          ? AndroidAppKey
          : HMAppKey;
    logCall('preInit', { appKey });
    SolarEngine.preInit(appKey);
  };

  const _initialize = (enabled = true): Promise<InitiateCompletionInfo> => {
    let appKey = '';
    if (Platform.OS === 'ios') {
      appKey = iOSAppKey;
    } else if (Platform.OS === 'android') {
      appKey = AndroidAppKey;
    } else {
      appKey = HMAppKey;
    }
    log('initialize platform: ' + Platform.OS);
    const initializeCase = enabled ? INITIALIZE_CASES[0] : INITIALIZE_CASES[1];
    logCall('initialize', {
      platform: Platform.OS,
      appKey,
      case: initializeCase.name,
    });
    const config = buildInitialConfig(enabled);
    logCall('initialize.config', buildInitialConfigSwitches(enabled));
    for (const presetCase of PRESET_EVENT_CASES) {
      logCall('setPresetEventProperties', presetCase);
      SolarEngine.setPreSetEventWithProperties(
        presetCase.eventType,
        presetCase.props
      );
    }

    const options: SolarEngineInitiateOptions = {
      config,
      remoteConfig: buildRemoteConfig(),
      attribution: handleAttribution,
      uaAttribution: handleUAAttribution,
      reAttribution: handleREAttribution,
      deeplink: handleDeepLink,
      deferredDeeplink: handleDeferredDeeplink,
    };

    return new Promise((resolve) => {
      SolarEngine.initialize(
        appKey,
        options,
        (result: InitiateCompletionInfo) => {
          log('Initialize result: ' + JSON.stringify(result));
          resolve(result);
        }
      );
    });
  };

  // Initialize with minimal config (only enableLog) to observe SDK default values.
  const _initializeMinimal = (): Promise<InitiateCompletionInfo> => {
    let appKey = '';
    if (Platform.OS === 'ios') {
      appKey = iOSAppKey;
    } else if (Platform.OS === 'android') {
      appKey = AndroidAppKey;
    } else {
      appKey = HMAppKey;
    }
    log('initialize (log-only) platform: ' + Platform.OS);
    logCall('initialize.logOnly', {
      platform: Platform.OS,
      appKey,
      config: { enableLog: true },
    });
    const options: SolarEngineInitiateOptions = {
      config: buildInitialConfigMinimal(),
      remoteConfig: buildRemoteConfig(),
      attribution: handleAttribution,
      uaAttribution: handleUAAttribution,
      reAttribution: handleREAttribution,
      deeplink: handleDeepLink,
      deferredDeeplink: handleDeferredDeeplink,
    };
    return new Promise((resolve) => {
      SolarEngine.initialize(
        appKey,
        options,
        (result: InitiateCompletionInfo) => {
          log('Initialize (log-only) result: ' + JSON.stringify(result));
          resolve(result);
        }
      );
    });
  };

  const _remoteConfigActions = {
    setDefault: () => {
      const defaultConfig: ConfigItem[] = [];
      const item1 = SolarEngine.stringItem('key_string', 'stringText1');
      const item2 = SolarEngine.numberItem('key_number', 22);
      const item3 = SolarEngine.booleanItem('key_boolean', true);

      const obj = {
        name: 'John',
        age: 30,
        hobbies: ['reading', 'coding', 'running'],
      };
      let item4 = SolarEngine.objectItem('key_object', obj);

      defaultConfig.push(item1);
      defaultConfig.push(item2);
      defaultConfig.push(item3);
      defaultConfig.push(item4);
      SolarEngine.setDefaultConfig(defaultConfig);

      logCall('setDefaultConfig', {
        key_string: 'stringText1',
        key_number: 22,
        key_boolean: true,
        key_object: obj,
      });
      log('remoteConfig.default.key_string = stringText1');
      log('remoteConfig.default.key_number = 22');
      log('remoteConfig.default.key_boolean = true');
      log('remoteConfig.default.key_object = ' + safeStringify(obj));
    },
    setEventProps: () => {
      logCall('setRemoteConfigEventProperties', {
        r_event_prop: 'val',
      });
      SolarEngine.setRemoteConfigEventProperties({ r_event_prop: 'val' });
    },
    setUserProps: () => {
      logCall('setRemoteConfigUserProperties', {
        r_user_prop: 'val',
      });
      SolarEngine.setRemoteConfigUserProperties({ r_user_prop: 'val' });
    },
    fastFetch: () => {
      logCall('fastFetchRemoteConfig');
      SolarEngine.fastFetchRemoteConfig((value) => {
        if (!value) return;
        const data = value as {
          key_string: string;
          key_boolean: boolean;
          key_object: { name: string; hobbies: string[]; age: number };
          key_number: number;
        };
        log('fastFetch string: ' + data.key_string);
        log('fastFetch boolean: ' + data.key_boolean);
        log('fastFetch number: ' + data.key_number);
        log('fastFetch name: ' + data.key_object.name);
        log('fastFetch age: ' + data.key_object.age);
        log('fastFetch hobbies: ' + data.key_object.hobbies);
      });
    },
    fastFetchKey: () => {
      logCall('fastFetchRemoteConfigWithKey', {
        keys: DEFAULT_RC_KEYS,
      });
      DEFAULT_RC_KEYS.forEach((key) => {
        SolarEngine.fastFetchRemoteConfigWithKey(key, (value) => {
          if (!value) return;
          logKeyValues(`fastFetchRemoteConfigWithKey.${key}`, value);
        });
      });
    },
    asyncFetch: () => {
      logCall('asyncFetchRemoteConfig');
      SolarEngine.asyncFetchRemoteConfig((value) => {
        if (!value) return;
        const data = value as {
          key_string: string;
          key_boolean: boolean;
          key_object: { name: string; hobbies: string[]; age: number };
          key_number: number;
        };
        log('asyncFetch string: ' + data.key_string);
        log('asyncFetch boolean: ' + data.key_boolean);
        log('asyncFetch number: ' + data.key_number);
        log('asyncFetch name: ' + data.key_object.name);
        log('asyncFetch age: ' + data.key_object.age);
        log('asyncFetch hobbies: ' + data.key_object.hobbies);
      });
    },
    asyncFetchKey: () => {
      logCall('asyncFetchRemoteConfigWithKey', {
        keys: DEFAULT_RC_KEYS,
      });
      DEFAULT_RC_KEYS.forEach((key) => {
        SolarEngine.asyncFetchRemoteConfigWithKey(key, (value) => {
          if (!value) return;
          logKeyValues(`asyncFetchRemoteConfigWithKey.${key}`, value);
        });
      });
    },
  };

  const _userActions = {
    setVisitorID: () => {
      logCall('setVisitorID', { visitorId: 'v_id_123' });
      SolarEngine.setVisitorID('v_id_123');
    },
    fetchVisitor: () => {
      logCall('fetchVisitor');
      if (Platform.OS === 'ios' || Platform.OS === 'android') {
        const visitorId = SolarEngine.fetchVisitor();
        log('visitorId: ' + visitorId);
      } else {
        SolarEngine.fetchVisitorWithCallback((res) => {
          log('visitorId: ' + res);
        });
      }
    },
    login: () => {
      logCall('login', { accountId: 'account_123' });
      SolarEngine.login('account_123');
    },
    logout: () => {
      logCall('logout');
      SolarEngine.logout();
    },
    fetchAccount: () => {
      logCall('fetchAccount');
      const accountId = SolarEngine.fetchAccount();
      log('accountId: ' + accountId);
    },
    fetchDistinctId: () => {
      logCall('fetchDistinctId');
      if (Platform.OS === 'ios' || Platform.OS === 'android') {
        const distinctId = SolarEngine.fetchDistinctId();
        log('distinctId: ' + distinctId);
      } else {
        SolarEngine.fetchDistinctIdWithCallback((res) => {
          log('distinctId: ' + res);
        });
      }
    },
    setGDPR: () => {
      logCall('setGDPRArea', { isGDPR: true });
      SolarEngine.setGDPRArea(true);
    },
    authorizationCompleted: () => {
      logCall('authorizationCompleted');
      SolarEngine.authorizationCompleted();
    },
    setInternalLogEnabled: (enabled: boolean) => {
      logCall('setInternalLogEnabled', { enabled });
      SolarEngine.setInternalLogEnabled(enabled);
    },
    requestPermissions: () => {
      logCall('requestPermissionsFromUser');
      SolarEngine.requestPermissionsFromUser((status) => {
        log('permission status: ' + status);
      });
    },
  };

  const _propertyActions = {
    setSuper: () => {
      const superProperties = { super_p: 'val', super_keep: 'keep' };
      const callId = logCall('setSuperProperties', superProperties);
      SolarEngine.setSuperProperties(superProperties);
      trackVerifyEvent('rn_verify_set_super', callId);
    },
    unsetSuper: () => {
      const callId = logCall('unsetSuperProperty', { key: 'super_p' });
      SolarEngine.unsetSuperProperty('super_p');
      trackVerifyEvent('rn_verify_unset_super', callId);
    },
    clearSuper: () => {
      const callId = logCall('clearSuperProperties');
      SolarEngine.clearSuperProperties();
      trackVerifyEvent('rn_verify_clear_super', callId);
    },
    getPreset: () => {
      logCall('retrievePresetProperties');
      if (Platform.OS === 'ios' || Platform.OS === 'android') {
        const preset = SolarEngine.retrievePresetProperties();
        log('preset: ' + safeStringify(preset));
        logKeyValues('preset', preset);
      } else {
        SolarEngine.retrievePresetPropertiesWithCallBack((res) => {
          log('preset: ' + JSON.stringify(res));
          logKeyValues('preset', res);
        });
      }
    },
    setPresetEvent: (
      eventType: PresetEventType = PRESET_EVENT_ALL,
      eventTypeName = 'ALL'
    ) => {
      logCall('setPresetEventProperties', {
        eventType,
        eventTypeName,
        sdkEventTypes: getSdkPresetEventTypes(eventType),
        props: PRESET_EVENT_PROPERTIES,
      });
      SolarEngine.setPreSetEventWithProperties(
        eventType,
        PRESET_EVENT_PROPERTIES
      );
    },
  };

  const _eventActions = {
    customNormal: () => {
      const callId = logCall('trackCustomEvent', {
        eventName: 'test_event_plain',
        props: {},
        preset: { _currency_type: 'USD', _pay_amount: 11 },
      });
      SolarEngine.trackCustomEvent('test_event_plain', withCallId({}, callId), {
        _currency_type: 'USD',
        _pay_amount: 11,
      });
    },
    customWithoutPrePropertiesNormal: () => {
      const callId = logCall('trackCustomEvent', {
        eventName: 'test_event_no_pre_properties_plain',
        props: {},
      });
      SolarEngine.trackCustomEvent(
        'test_event_no_pre_properties_plain',
        withCallId({}, callId)
      );
    },
    firstNormal: () => {
      const firstEventRunSuffix = `${Date.now()}_${Math.random().toString(16).slice(2, 8)}`;
      const registerFirstCheckId = `first_check_plain_1_${firstEventRunSuffix}`;
      const customFirstCheckId = `first_check_plain_2_${firstEventRunSuffix}`;
      const callId = logCall('trackFirstEvent', {
        eventName: registerFirstCheckId,
        props: { registerType: 'WeChat', registerStatus: 'success' },
      });
      SolarEngine.trackFirstEvent(registerFirstCheckId, {
        registerType: 'WeChat',
        registerStatus: 'success',
        customProperties: withCallId({}, callId),
      });
      logCall('trackFirstEvent', {
        eventName: customFirstCheckId,
        props: {
          eventName: 'Customtest_plain',
          preProperties: { _currency_type: 'USD', _pay_amount: 11 },
        },
      });
      SolarEngine.trackFirstEvent(customFirstCheckId, {
        eventName: 'Customtest_plain',
        customProperties: {},
        preProperties: { _currency_type: 'USD', _pay_amount: 11 },
      });
    },
    startNormal: () => {
      logCall('eventStart', { eventName: 'timer_event_plain' });
      SolarEngine.eventStart('timer_event_plain');
    },
    endNormal: () => {
      const callId = logCall('eventEnd', {
        eventName: 'timer_event_plain',
        props: {},
      });
      SolarEngine.eventEnd('timer_event_plain', withCallId({}, callId));
    },
    custom: () => {
      const callId = logCall('trackCustomEvent', {
        eventName: 'test_event',
        props: {},
        preset: { _currency_type: 'USD', _pay_amount: 11 },
        eventAlias: '自定义事件别名_带预置属性',
      });
      const customProps = withCallId({}, callId);
      SolarEngine.trackCustomEvent(
        'test_event',
        customProps,
        {
          _currency_type: 'USD',
          _pay_amount: 11,
        },
        '自定义事件别名_带预置属性'
      ); // eventAlias
    },
    customWithoutPreProperties: () => {
      const callId = logCall('trackCustomEvent', {
        eventName: 'test_event_no_pre_properties',
        props: {},
        eventAlias: '自定义事件别名_无预置属性',
      });
      SolarEngine.trackCustomEvent(
        'test_event_no_pre_properties',
        withCallId({}, callId),
        undefined,
        '自定义事件别名_无预置属性'
      );
    },
    first: () => {
      const firstEventRunSuffix = `${Date.now()}_${Math.random().toString(16).slice(2, 8)}`;
      const registerFirstCheckId = `first_check_1_ios-run-20260714-154946_rn-ios-sim-20260714_rn-ios-dialog-20260714_${firstEventRunSuffix}`;
      const customFirstCheckId = `first_check_2_ios-run-20260714-154946_rn-ios-sim-20260714_rn-ios-dialog-20260714_${firstEventRunSuffix}`;
      const callId1 = logCall('trackFirstEvent', {
        eventName: registerFirstCheckId,
        props: {
          registerType: 'WeChat',
          registerStatus: 'success',
          customProperties: { key: 'test' },
        },
      });
      SolarEngine.trackFirstEvent(registerFirstCheckId, {
        registerType: 'WeChat',
        registerStatus: 'success',
        customProperties: withCallId({ key: 'test' }, callId1),
      });
      logCall('trackFirstEvent', {
        eventName: customFirstCheckId,
        props: {
          eventName: 'Customtest',
          customProperties: { key: 'test' },
          preProperties: { _currency_type: 'USD', _pay_amount: 11 },
          eventAlias: '首次自定义事件别名',
        },
      });
      SolarEngine.trackFirstEvent(customFirstCheckId, {
        eventName: 'Customtest',
        customProperties: { key: 'test' },
        preProperties: { _currency_type: 'USD', _pay_amount: 11 },
        eventAlias: '首次自定义事件别名', // eventAlias (Custom type only)
      });
    },
    start: () => {
      logCall('eventStart', { eventName: 'timer_event' });
      SolarEngine.eventStart('timer_event');
    },
    end: () => {
      const callId = logCall('eventEnd', {
        eventName: 'timer_event',
        props: {},
        eventAlias: '计时事件别名',
      });
      SolarEngine.eventEnd(
        'timer_event',
        withCallId({}, callId),
        '计时事件别名'
      ); // eventAlias
    },
    reportNow: () => {
      logCall('reportEventimmediately');
      SolarEngine.reportEventimmediately();
    },
  };

  const _specificActions = {
    adImp: () => {
      const callId = logCall('trackAdImpressionWithAttributes', {
        adNetworkPlatform: 'AdMob',
        adType: AdType.Interstitial,
        adNetworkAppID: 'appid',
        adNetworkPlacementID: 'pid',
        mediationPlatform: 'MAX',
        currency: 'USD',
        ecpm: 1.234,
        rendered: true,
        customProperties: { key: 'test' },
      });
      SolarEngine.trackAdImpressionWithAttributes({
        adNetworkPlatform: 'AdMob',
        adType: AdType.Interstitial,
        adNetworkAppID: 'appid',
        adNetworkPlacementID: 'pid',
        mediationPlatform: 'MAX',
        currency: 'USD',
        ecpm: 1.234,
        rendered: true,
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    adClick: () => {
      const callId = logCall('trackAdClickWithAttributes', {
        adNetworkPlatform: 'Network',
        adType: AdType.Interstitial,
        adNetworkPlacementID: 'pid',
        mediationPlatform: 'mediation',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackAdClickWithAttributes({
        adNetworkPlatform: 'Network',
        adType: AdType.Interstitial,
        adNetworkPlacementID: 'pid',
        mediationPlatform: 'mediation',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    iap: () => {
      const callId = logCall('trackIAPWithAttributes', {
        productID: 'pid',
        productName: 'name',
        productCount: 3,
        orderId: 'oid',
        payAmount: 3.14,
        currency: 'USD',
        payType: Paypal,
        payStatus: SEIAPStatus.Success,
        failReason: '',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackIAPWithAttributes({
        productID: 'pid',
        productName: 'name',
        productCount: 3,
        orderId: 'oid',
        payAmount: 3.14,
        currency: 'USD',
        payType: Paypal,
        payStatus: SEIAPStatus.Success,
        failReason: '',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    appAttr: () => {
      const callId = logCall('trackAppAttrWithAttributes', {
        adNetwork: 'toutiao',
        subChannel: '103300',
        adAccountID: '123',
        adAccountName: 'test',
        adCampaignID: '123',
        adCampaignName: 'test',
        adOfferID: '123',
        adOfferName: 'test',
        adCreativeID: '123',
        adCreativeName: 'test',
        attributionPlatform: 'platform',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackAppAttrWithAttributes({
        adNetwork: 'toutiao',
        subChannel: '103300',
        adAccountID: '123',
        adAccountName: 'test',
        adCampaignID: '123',
        adCampaignName: 'test',
        adOfferID: '123',
        adOfferName: 'test',
        adCreativeID: '123',
        adCreativeName: 'test',
        attributionPlatform: 'platform',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    order: () => {
      const callId = logCall('trackOrderWithAttributes', {
        orderID: 'oid',
        payAmount: 3.14,
        currency: 'USD',
        payType: Paypal,
        status: 'success',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackOrderWithAttributes({
        orderID: 'oid',
        payAmount: 3.14,
        currency: 'USD',
        payType: Paypal,
        status: 'success',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    register: () => {
      const callId = logCall('trackRegisterWithAttributes', {
        registerType: 'WeChat',
        registerStatus: 'success',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackRegisterWithAttributes({
        registerType: 'WeChat',
        registerStatus: 'success',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    login: () => {
      const callId = logCall('trackLoginWithAttributes', {
        loginType: 'WeChat',
        loginStatus: 'failed',
        customProperties: { key: 'test' },
      });
      SolarEngine.trackLoginWithAttributes({
        loginType: 'WeChat',
        loginStatus: 'failed',
        customProperties: withCallId({ key: 'test' }, callId),
      });
    },
    reEngagement: () => {
      logCall('trackAppReEngagement', { key: 'test' });
      SolarEngine.trackAppReEngagement({ key: 'test' });
    },
  };

  const _userPropActions = {
    init: () => {
      logCall('userPropertiesInit', { age: 20 });
      SolarEngine.userPropertiesInit({ age: 20 });
    },
    update: () => {
      logCall('userPropertiesUpdate', { age: 21 });
      SolarEngine.userPropertiesUpdate({ age: 21 });
    },
    add: () => {
      const map = new Map();
      map.set('score', 10);
      logCall('userPropertiesAdd', { score: 10 });
      SolarEngine.userPropertiesAdd(map);
    },
    unset: () => {
      logCall('userPropertiesUnset', ['rn_unset_marker']);
      SolarEngine.userPropertiesUnset(['rn_unset_marker']);
    },
    append: () => {
      logCall('userPropertiesAppend', { tags: 'new_tag' });
      SolarEngine.userPropertiesAppend({ tags: 'new_tag' });
    },
    delete: () => {
      logCall('userPropertiesDelete', {
        types: [SEUserDeleteType.ByAccountId, SEUserDeleteType.ByVisitorId],
        accountId: 'account_123',
        visitorId: 'v_id_123',
      });
      SolarEngine.setVisitorID('v_id_123');
      SolarEngine.login('account_123');
      SolarEngine.userPropertiesDelete(SEUserDeleteType.ByAccountId);
      SolarEngine.userPropertiesDelete(SEUserDeleteType.ByVisitorId);
    },
  };

  const _attrActions = {
    retrieveAttr: () => {
      logCall('retrieveAttribution');
      const result = SolarEngine.retrieveAttribution();
      log('Attribution: ' + JSON.stringify(result));
    },
    getUAAttr: () => {
      logCall('getUAAttributionData');
      log(
        'UA Attribution: payload=' +
          safeStringify(SolarEngine.getUAAttributionData())
      );
    },
    getREAttr: () => {
      logCall('getREAttributionData');
      log(
        'RE Attribution: payload=' +
          safeStringify(SolarEngine.getREAttributionData())
      );
    },
    openUrl: () => {
      const url = 'link://www.example.com/programs?action=showall';
      logCall('appDeeplinkOpenURL', { url });
      SolarEngine.appDeeplinkOpenURL(url);
    },
  };

  const _platformActions = {
    iosATT: () => {
      logCall('requestTrackingAuthorization');
      SolarEngine.requestTrackingAuthorization((s) => {
        log('ATT status: ' + s);
      });
    },
    iosSKAN: () => {
      logCall('updatePostbackConversionValue', {
        value: 1,
        coarseType: SKAdNetworkCoarseType.High,
        lock: false,
      });
      SolarEngine.updatePostbackConversionValue(
        1,
        SKAdNetworkCoarseType.High,
        false
      ).then((e) => {
        log('SKAN error: ' + JSON.stringify(e));
      });
    },
    setOAID: () => {
      const callId = logCall('setOaid', { oaid: 'oaid_123' });
      SolarEngine.setOaid('oaid_123');
      if (Platform.OS === 'android') {
        trackVerifyEvent('rn_verify_set_oaid', callId);
      }
    },
    setGAID: () => {
      const callId = logCall('setGaid', { gaid: 'gaid_123' });
      SolarEngine.setGaid('gaid_123');
      if (Platform.OS === 'android') {
        trackVerifyEvent('rn_verify_set_gaid', callId);
      }
    },
    setChannel: () => {
      const callId = logCall('setChannel', { channel: 'channel_123' });
      SolarEngine.setChannel('channel_123');
      if (Platform.OS === 'android') {
        trackVerifyEvent('rn_verify_set_channel', callId);
      }
    },
  };

  const autoRunActionsRef = useRef({
    _attrActions,
    _eventActions,
    _platformActions,
    _propertyActions,
    _remoteConfigActions,
    _specificActions,
    _userActions,
    _userPropActions,
  });

  autoRunActionsRef.current = {
    _attrActions,
    _eventActions,
    _platformActions,
    _propertyActions,
    _remoteConfigActions,
    _specificActions,
    _userActions,
    _userPropActions,
  };

  useEffect(() => {
    if (!IOS_AUTO_RUN_CASES || Platform.OS !== 'ios') {
      return;
    }

    const {
      _attrActions: attrActions,
      _eventActions: eventActions,
      _platformActions: platformActions,
      _propertyActions: propertyActions,
      _remoteConfigActions: remoteConfigActions,
      _specificActions: specificActions,
      _userActions: userActions,
      _userPropActions: userPropActions,
    } = autoRunActionsRef.current;

    const autoRunState = getIosAutoRunState();
    if (autoRunState.started) {
      log('[IOS CASE] auto-run already started, skip duplicate effect');
      return;
    }
    autoRunState.started = true;

    const runStep = async (
      name: string,
      action: () => void | Promise<void>
    ) => {
      log(`[IOS CASE] start ${name}`);
      try {
        await action();
        log(`[IOS CASE] done ${name}`);
      } catch (error) {
        log(`[IOS CASE] failed ${name}: ${safeStringify(error)}`);
      }
      await delay(1200);
    };

    const runCases = async () => {
      await delay(1500);
      if (IOS_AUTO_RUN_ALL_FALSE_ONLY) {
        log('[IOS CASE] all-false auto-run begin');
        await runStep('preInitAllFalseConfig', () => _preInit());
        await runStep('initializeAllFalseConfig', async () => {
          await _initialize(false);
        });
        await delay(5000);
        log('[IOS CASE] all-false auto-run complete');
        autoRunState.completed = true;
        return;
      }
      log('[IOS CASE] auto-run begin');
      await runStep('preInit', () => _preInit());
      await runStep('initialize', async () => {
        await _initialize();
      });
      await delay(8000);
      await runStep('setVisitorID', () => userActions.setVisitorID());
      await runStep('getVisitorID', () => userActions.fetchVisitor());
      await runStep('getDistinctId', () => userActions.fetchDistinctId());
      await runStep('login', () => userActions.login());
      await runStep('getAccountID', () => userActions.fetchAccount());
      await runStep('logout', () => userActions.logout());
      await runStep('getAccountIDAfterLogout', () =>
        userActions.fetchAccount()
      );
      await runStep('setGDPRArea', () => userActions.setGDPR());
      await runStep('setSuperProperties', () => propertyActions.setSuper());
      await runStep('unsetSuperProperty', () => propertyActions.unsetSuper());
      await runStep('clearSuperProperties', () => propertyActions.clearSuper());
      await runStep('getPresetProperties', () => propertyActions.getPreset());
      await runStep('trackCustomEvent', () => eventActions.custom());
      await runStep('trackCustomEventWithoutPreProperties', () =>
        eventActions.customWithoutPreProperties()
      );
      await runStep('trackFirstEvent', () => eventActions.first());
      await runStep('eventStart', () => eventActions.start());
      await delay(1800);
      await runStep('eventEnd', () => eventActions.end());
      await runStep('trackCustomEventPlain', () => eventActions.customNormal());
      await runStep('trackCustomEventWithoutPrePropertiesPlain', () =>
        eventActions.customWithoutPrePropertiesNormal()
      );
      await runStep('trackFirstEventPlain', () => eventActions.firstNormal());
      await runStep('eventStartPlain', () => eventActions.startNormal());
      await delay(1800);
      await runStep('eventEndPlain', () => eventActions.endNormal());
      await runStep('trackAdImpression', () => specificActions.adImp());
      await runStep('trackAdClick', () => specificActions.adClick());
      await runStep('trackIAP', () => specificActions.iap());
      await runStep('trackAppAttr', () => specificActions.appAttr());
      await runStep('trackOrder', () => specificActions.order());
      await runStep('trackRegister', () => specificActions.register());
      await runStep('trackLogin', () => specificActions.login());
      await runStep('userInit', () => userPropActions.init());
      await runStep('userUpdate', () => userPropActions.update());
      await runStep('userAdd', () => userPropActions.add());
      await runStep('userUnset', () => userPropActions.unset());
      await runStep('userAppend', () => userPropActions.append());
      await runStep('userDelete', () => userPropActions.delete());
      await runStep('getAttribution', () => attrActions.retrieveAttr());
      await runStep('setDefaultConfig', () => remoteConfigActions.setDefault());
      await runStep('setRemoteConfigEventProperties', () =>
        remoteConfigActions.setEventProps()
      );
      await runStep('setRemoteConfigUserProperties', () =>
        remoteConfigActions.setUserProps()
      );
      await runStep('asyncFetchRemoteConfig', () =>
        remoteConfigActions.asyncFetch()
      );
      await delay(3000);
      await runStep('fastFetchRemoteConfig', () =>
        remoteConfigActions.fastFetch()
      );
      await runStep('fastFetchRemoteConfigWithKey', () =>
        remoteConfigActions.fastFetchKey()
      );
      await runStep('asyncFetchRemoteConfigWithKey', () =>
        remoteConfigActions.asyncFetchKey()
      );
      await runStep('requestTrackingAuthorization', () =>
        platformActions.iosATT()
      );
      await runStep('updatePostbackConversionValue', () =>
        platformActions.iosSKAN()
      );
      await runStep('iOSUnsupportedSetOaid', () => platformActions.setOAID());
      await runStep('iOSUnsupportedSetGaid', () => platformActions.setGAID());
      await runStep('iOSUnsupportedSetChannel', () =>
        platformActions.setChannel()
      );
      await runStep('reportEventimmediately', () => eventActions.reportNow());
      await delay(5000);
      log('[IOS CASE] auto-run complete');
      autoRunState.completed = true;
    };

    runCases().catch((error) => {
      log(`[IOS CASE] auto-run failed: ${safeStringify(error)}`);
    });
  }, []);

  return (
    <SafeAreaView
      style={[
        styles.container,
        { backgroundColor: isDarkMode ? '#121212' : '#f5f5f5' },
      ]}
    >
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <View style={styles.header}>
        <Text
          style={[styles.headerTitle, { color: isDarkMode ? '#fff' : '#000' }]}
        >
          SolarEngine SDK Demo CN
        </Text>
        <Text
          style={[
            styles.headerSubtitle,
            { color: isDarkMode ? '#bdbdbd' : '#616161' },
          ]}
        >
          {platformDemoLabel}
        </Text>
        <Text
          style={[
            styles.headerSubtitle,
            { color: isDarkMode ? '#bdbdbd' : '#616161' },
          ]}
        >
          {sdkVersionLabel}
        </Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Section title="初始化">
          <DemoButton title="Pre-Init1111" onPress={_preInit} />
          {INITIALIZE_CASES.map((initializeCase) => (
            <DemoButton
              key={initializeCase.name}
              title={initializeCase.title}
              onPress={() => _initialize(initializeCase.enabled)}
            />
          ))}
          <DemoButton
            title="Initialize (log only)"
            color="#FF9800"
            onPress={_initializeMinimal}
          />
        </Section>

        <Section title="用户操作">
          <DemoButton
            title="Set Visitor ID"
            onPress={_userActions.setVisitorID}
          />
          <DemoButton title="Get Visitor" onPress={_userActions.fetchVisitor} />
          <DemoButton title="Account Login" onPress={_userActions.login} />
          <DemoButton title="Logout" onPress={_userActions.logout} />
          <DemoButton title="Get Account" onPress={_userActions.fetchAccount} />
          <DemoButton
            title="Distinct ID"
            onPress={_userActions.fetchDistinctId}
          />
          <DemoButton title="Set GDPR" onPress={_userActions.setGDPR} />
          <DemoButton
            title="Auth Completed"
            onPress={_userActions.authorizationCompleted}
          />
          <DemoButton
            title="Internal Log On"
            onPress={() => _userActions.setInternalLogEnabled(true)}
          />
          <DemoButton
            title="Internal Log Off"
            onPress={() => _userActions.setInternalLogEnabled(false)}
          />
          <DemoButton
            title="Request Permissions"
            onPress={_userActions.requestPermissions}
          />
        </Section>

        <Section title="属性设置">
          <DemoButton title="Set Super" onPress={_propertyActions.setSuper} />
          <DemoButton
            title="Unset Super"
            onPress={_propertyActions.unsetSuper}
          />
          <DemoButton
            title="Clear Super"
            onPress={_propertyActions.clearSuper}
          />
          <DemoButton title="Get Preset" onPress={_propertyActions.getPreset} />
          <DemoButton
            title="Set Preset Events"
            onPress={_propertyActions.setPresetEvent}
          />
        </Section>

        <Section title="渠道&ID">
          <DemoButton
            title="Set OAID"
            onPress={_platformActions.setOAID}
            color="#4CAF50"
          />
          <DemoButton
            title="Set GAID"
            onPress={_platformActions.setGAID}
            color="#4CAF50"
          />
          <DemoButton
            title="Set Channel"
            onPress={_platformActions.setChannel}
            color="#4CAF50"
          />
        </Section>

        <Section title="事件埋点">
          <DemoButton
            title="Custom Event"
            onPress={_eventActions.customNormal}
          />
          <DemoButton
            title="Custom Event No PreProperties"
            onPress={_eventActions.customWithoutPrePropertiesNormal}
          />
          <DemoButton title="First Event" onPress={_eventActions.firstNormal} />
          <DemoButton title="Event Start" onPress={_eventActions.startNormal} />
          <DemoButton title="Event End" onPress={_eventActions.endNormal} />
          <DemoButton title="Report Now" onPress={_eventActions.reportNow} />
        </Section>

        <Section title="事件别名 eventAlias (1.3.2)">
          <DemoButton
            title="Custom Event + PreProperties + alias"
            onPress={_eventActions.custom}
            color="#4CAF50"
          />
          <DemoButton
            title="Custom Event No PreProperties + alias"
            onPress={_eventActions.customWithoutPreProperties}
            color="#4CAF50"
          />
          <DemoButton
            title="First Event(Custom) + alias"
            onPress={_eventActions.first}
            color="#4CAF50"
          />
          <DemoButton
            title="Event Start"
            onPress={_eventActions.start}
            color="#4CAF50"
          />
          <DemoButton
            title="Event End + alias"
            onPress={_eventActions.end}
            color="#4CAF50"
          />
        </Section>

        <Section title="业务事件">
          <DemoButton title="AD Imp" onPress={_specificActions.adImp} />
          <DemoButton title="AD Click" onPress={_specificActions.adClick} />
          <DemoButton title="IAP" onPress={_specificActions.iap} />
          <DemoButton title="App Attr" onPress={_specificActions.appAttr} />
          <DemoButton title="Order" onPress={_specificActions.order} />
          <DemoButton title="Register" onPress={_specificActions.register} />
          <DemoButton title="Business Login" onPress={_specificActions.login} />
          <DemoButton
            title="Re-Engagement"
            onPress={_specificActions.reEngagement}
          />
        </Section>

        <Section title="用户属性">
          <DemoButton title="Init" onPress={_userPropActions.init} />
          <DemoButton title="Update" onPress={_userPropActions.update} />
          <DemoButton title="Add" onPress={_userPropActions.add} />
          <DemoButton title="Unset" onPress={_userPropActions.unset} />
          <DemoButton title="Append" onPress={_userPropActions.append} />
          <DemoButton title="Delete" onPress={_userPropActions.delete} />
        </Section>

        <Section title="归因与DeepLink">
          <DemoButton
            title="Retrieve Attr"
            onPress={_attrActions.retrieveAttr}
          />
          <DemoButton title="Open URL" onPress={_attrActions.openUrl} />
          <DemoButton
            title="Get UA Attribution"
            onPress={_attrActions.getUAAttr}
          />
          <DemoButton
            title="Get RE Attribution"
            onPress={_attrActions.getREAttr}
          />
        </Section>

        <Section title="远程配置">
          <DemoButton
            title="Set Defaults"
            onPress={_remoteConfigActions.setDefault}
          />
          <DemoButton
            title="Set Event Props"
            onPress={_remoteConfigActions.setEventProps}
          />
          <DemoButton
            title="Set User Props"
            onPress={_remoteConfigActions.setUserProps}
          />
          <DemoButton
            title="Fast Fetch"
            onPress={_remoteConfigActions.fastFetch}
          />
          <DemoButton
            title="Fast Fetch Key"
            onPress={_remoteConfigActions.fastFetchKey}
          />
          <DemoButton
            title="Async Fetch"
            onPress={_remoteConfigActions.asyncFetch}
          />
          <DemoButton
            title="Async Fetch Key"
            onPress={_remoteConfigActions.asyncFetchKey}
          />
        </Section>

        <Section title="平台专用">
          {Platform.OS === 'ios' && (
            <>
              <DemoButton
                title="Request ATT"
                onPress={_platformActions.iosATT}
                color="#009688"
              />
              <DemoButton
                title="SKAN Update"
                onPress={_platformActions.iosSKAN}
                color="#009688"
              />
            </>
          )}
        </Section>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: {
    padding: 20,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#ddd',
  },
  headerTitle: { fontSize: 22, fontWeight: 'bold' },
  headerSubtitle: { marginTop: 6, fontSize: 13, fontWeight: '600' },
  scrollContent: { paddingBottom: 40 },
  section: { marginTop: 20, paddingHorizontal: 15 },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 10,
    color: '#616161',
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
    paddingLeft: 10,
  },
  buttonGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'flex-start',
  },
  buttonWrapper: { width: '48%', margin: '1%' },
});
