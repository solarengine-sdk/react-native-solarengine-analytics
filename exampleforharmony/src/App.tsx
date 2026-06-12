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

const AndroidAppKey = '82770189c354de18';
//const iOSAppKey = '07df077973a84ea7';//海外b012bf6e500c84db

const iOSAppKey = '16e503718a7305f5'; //海外b012bf6e500c84db

const HMAppKey = '16e503718a7305f5';

const LOG_PREFIX = '[SeSDK Demo]';
let logSeq = 0;

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

const IOS_AUTO_RUN_CASES = false;

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
const PRESET_EVENT_TYPES =
  PresetEventType.INSTALL | PresetEventType.START | PresetEventType.END;

const trackVerifyEvent = (eventName: string, callId: number) => {
  SolarEngine.trackCustomEvent(eventName, withCallId({}, callId), {
    _currency_type: 'USD',
    _pay_amount: 1,
  });
};

function buildInitialConfig(): se_initial_config {
  return {
    enableLog: true,
    enableDebug: true,
    enable2G: true,
    enableGDPR: true,

    enableUserData: true,
    enableCoppa: true,
    enableKidsApp: true,
    enableDeferredDeeplink: true,
    android: {
      enablePersonalizedAd: true,
    },
    ios: {
      attAuthorizationWaitingInterval: 60,
      caid: '[{"version":"20220111","caid":"912ec803b2ce49e4a541068d495ab570"}]',
    },
    harmony: {
      authorizationTimeout: 100,
    },
  };
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
    const appKey = Platform.OS === 'android' ? AndroidAppKey : HMAppKey;
    logCall('preInit', { appKey });
    SolarEngine.preInit(appKey);
  };

  const _initialize = (): Promise<InitiateCompletionInfo> => {
    let appKey = '';
    if (Platform.OS === 'ios') {
      appKey = iOSAppKey;
    } else if (Platform.OS === 'android') {
      appKey = AndroidAppKey;
    } else {
      appKey = HMAppKey;
    }
    log('initialize platform: ' + Platform.OS);
    logCall('initialize', { platform: Platform.OS, appKey });
    logCall('setPreSetEventWithProperties.beforeInitialize', {
      eventType: PRESET_EVENT_TYPES,
      props: PRESET_EVENT_PROPERTIES,
    });
    SolarEngine.setPreSetEventWithProperties(
      PRESET_EVENT_TYPES,
      PRESET_EVENT_PROPERTIES
    );

    const options: SolarEngineInitiateOptions = {
      config: buildInitialConfig(),
      remoteConfig: buildRemoteConfig(),
      attribution: handleAttribution,
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

  const _remoteConfigActions = {
    setDefault: () => {
      let defaultConfig: Array<ConfigItem> = new Array();
      let item1 = SolarEngine.stringItem('key_string', 'stringText1');
      let item2 = SolarEngine.numberItem('key_number', 22);
      let item3 = SolarEngine.booleanItem('key_boolean', true);

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
    setPresetEvent: () => {
      logCall('setPreSetEventWithProperties', {
        eventType: PRESET_EVENT_TYPES,
        props: PRESET_EVENT_PROPERTIES,
      });
      SolarEngine.setPreSetEventWithProperties(
        PRESET_EVENT_TYPES,
        PRESET_EVENT_PROPERTIES
      );
    },
  };

  const _eventActions = {
    custom: () => {
      const callId = logCall('trackCustomEvent', {
        eventName: 'test_event',
        props: {},
        preset: { _currency_type: 'USD', _pay_amount: 11 },
      });
      const customProps = withCallId({}, callId);
      SolarEngine.trackCustomEvent('test_event', customProps, {
        _currency_type: 'USD',
        _pay_amount: 11,
      });
    },
    first: () => {
      const callId1 = logCall('trackFirstEvent', {
        eventName: 'first_check_1',
        props: {
          registerType: 'WeChat',
          registerStatus: 'success',
          customProperties: { key: 'test' },
        },
      });
      SolarEngine.trackFirstEvent('first_check_1', {
        registerType: 'WeChat',
        registerStatus: 'success',
        customProperties: withCallId({ key: 'test' }, callId1),
      });
      logCall('trackFirstEvent', {
        eventName: 'first_check_2',
        props: {
          eventName: 'Customtest',
          customProperties: { key: 'test' },
          preProperties: { _currency_type: 'USD', _pay_amount: 11 },
        },
      });
      SolarEngine.trackFirstEvent('first_check_2', {
        eventName: 'Customtest',
        customProperties: { key: 'test' },
        preProperties: { _currency_type: 'USD', _pay_amount: 11 },
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
      });
      SolarEngine.eventEnd('timer_event', withCallId({}, callId));
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
      trackVerifyEvent('rn_verify_set_oaid', callId);
    },
    setGAID: () => {
      const callId = logCall('setGaid', { gaid: 'gaid_123' });
      SolarEngine.setGaid('gaid_123');
      trackVerifyEvent('rn_verify_set_gaid', callId);
    },
    setChannel: () => {
      const callId = logCall('setChannel', { channel: 'channel_123' });
      SolarEngine.setChannel('channel_123');
      trackVerifyEvent('rn_verify_set_channel', callId);
    },
  };

  const autoRunActionsRef = useRef({
    preInit: _preInit,
    initialize: _initialize,
    remoteConfigActions: _remoteConfigActions,
    userActions: _userActions,
    propertyActions: _propertyActions,
    eventActions: _eventActions,
    specificActions: _specificActions,
    userPropActions: _userPropActions,
    attrActions: _attrActions,
    platformActions: _platformActions,
  });

  autoRunActionsRef.current = {
    preInit: _preInit,
    initialize: _initialize,
    remoteConfigActions: _remoteConfigActions,
    userActions: _userActions,
    propertyActions: _propertyActions,
    eventActions: _eventActions,
    specificActions: _specificActions,
    userPropActions: _userPropActions,
    attrActions: _attrActions,
    platformActions: _platformActions,
  };

  useEffect(() => {
    if (!IOS_AUTO_RUN_CASES || Platform.OS !== 'ios') {
      return;
    }

    let cancelled = false;

    const runStep = async (
      name: string,
      action: () => void | Promise<void>
    ) => {
      if (cancelled) {
        return;
      }
      log(`[ANDROID CASE] start ${name}`);
      try {
        await action();
        log(`[ANDROID CASE] done ${name}`);
      } catch (error) {
        log(`[ANDROID CASE] failed ${name}: ${safeStringify(error)}`);
      }
      await delay(1200);
    };

    const runCases = async () => {
      const {
        preInit,
        initialize,
        remoteConfigActions,
        userActions,
        propertyActions,
        eventActions,
        specificActions,
        userPropActions,
        attrActions,
        platformActions,
      } = autoRunActionsRef.current;

      await delay(1500);
      log('[ANDROID CASE] auto-run begin');
      await runStep('preInit', () => preInit());
      await runStep('initialize', async () => {
        await initialize();
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
      await runStep('setPresetEventProperties', () =>
        propertyActions.setPresetEvent()
      );
      await runStep('trackCustomEvent', () => eventActions.custom());
      await runStep('trackFirstEvent', () => eventActions.first());
      await runStep('eventStart', () => eventActions.start());
      await delay(1800);
      await runStep('eventEnd', () => eventActions.end());
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
      await runStep('fastFetchRemoteConfig', () =>
        remoteConfigActions.fastFetch()
      );
      await runStep('fastFetchRemoteConfigWithKey', () =>
        remoteConfigActions.fastFetchKey()
      );
      await runStep('asyncFetchRemoteConfig', () =>
        remoteConfigActions.asyncFetch()
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
      log('[ANDROID CASE] auto-run complete');
    };

    runCases();

    return () => {
      cancelled = true;
    };
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
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Section title="初始化">
          <DemoButton title="Pre-Init1111" onPress={_preInit} />
          <DemoButton title="Initialize" onPress={_initialize} />
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
          <DemoButton title="Custom Event" onPress={_eventActions.custom} />
          <DemoButton title="First Event" onPress={_eventActions.first} />
          <DemoButton title="Event Start" onPress={_eventActions.start} />
          <DemoButton title="Event End" onPress={_eventActions.end} />
          <DemoButton title="Report Now" onPress={_eventActions.reportNow} />
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
