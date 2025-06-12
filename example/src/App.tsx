import { StyleSheet, View, Text, Button, Alert, Platform } from 'react-native';
import { preInit, multiply } from 'solarengine-analysis-react-native';
import * as SolarEngine from 'solarengine-analysis-react-native';

import type {
  RemoteConfig,
  se_initial_config,
  deeplink,
  deferredDeeplink,
  attribution,
  SolarEngineInitiateOptions,
  InitiateCompletionInfo,
  DeepLinkInfo,
  DeferredDeepLinkInfo,
  requestTrackingAuthorizationCompletion,
  SEAdImpressionEventAttribute,
  SEAdClickEventAttribute,
  SEIAPEventAttribute,
  SEAppAttrEventAttribute,
  SEOrderEventAttribute,
  SERegisterEventAttribute,
  SELoginEventAttribute,
  ConfigItem,
  SECustomEventAttribute,
  AttributionInfo,
} from 'solarengine-analysis-react-native';
import {
  SEUserDeleteType,
  RemoteConfigMergeType,
  ATTrackingManagerAuthorizationStatus,
  PresetEventType,
  AdType,
  SKAdNetworkCoarseType,
  SEIAPStatus,
  Paypal,
} from 'solarengine-analysis-react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text> Solarengine ReactNative</Text>
      <Button onPress={_onPressButton} title="SDK Initiate" color="#841584" />
      <View style={{ marginVertical: 30 }} />
      <Button
        onPress={_requestRemoteConfig}
        title="Remote Configs"
        color="#141584"
      />
    </View>
  );
}
function _requestRemoteConfig() {
  /*
  setDefaultConfig,
  setRemoteConfigEventProperties,
  setRemoteConfigUserProperties,
  fastFetchRemoteConfigWithKey,
  fastFetchRemoteConfig,
  asyncFetchRemoteConfigWithKey,
  asyncFetchRemoteConfig
*/

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

  const eventProperties = {
    key1: 'stringText2',
    key2: 222,
    key3: true,
  };

  const userProperties = {
    user_key1: 'stringText3',
    user_key2: 2222,
    user_key3: true,
  };
  SolarEngine.setRemoteConfigEventProperties(eventProperties);
  SolarEngine.setRemoteConfigUserProperties(userProperties);

  SolarEngine.fastFetchRemoteConfig((value: Object | null) => {
    if (value != null) {
      log(
        'fastFetchRemoteConfig, JSON.stringify result: ' + JSON.stringify(value)
      );

      const typedValue = value as {
        key_string: string;
        key_boolean: boolean;
        key_object: object;
        key_number: string;
      };
      log('fastFetchRemoteConfig, key_string: ' + typedValue.key_string);
      log('fastFetchRemoteConfig, key_boolean: ' + typedValue.key_boolean);

      log(
        'fastFetchRemoteConfig, key_number typeOf: ' +
          typeof typedValue.key_number
      );

      log('fastFetchRemoteConfig, key_number: ' + typedValue.key_number);

      log(
        'fastFetchRemoteConfig, key_object typeOf: ' +
          typeof typedValue.key_object
      );

      const key_objectValue = typedValue.key_object as {
        name: string;
        hobbies: string[];
        age: number;
      };
      if (key_objectValue && typeof key_objectValue === 'object') {
        const nameValue = key_objectValue.name;
        const ageValue = key_objectValue.age;
        const hobbies = key_objectValue.hobbies;
        log('fastFetchRemoteConfig, nameValue: ' + nameValue);
        log('fastFetchRemoteConfig, ageValue: ' + ageValue);
        log('fastFetchRemoteConfig, hobbies: ' + hobbies);
      } else {
        console.warn(
          'key_objectValue is undefined or not an object',
          key_objectValue
        );
      }
    }
  });

  SolarEngine.fastFetchRemoteConfigWithKey(
    'key_string',
    (value: object | null) => {
      if (value != null) {
        log(
          'fastFetchRemoteConfigWithKey, key_string: ' +
            value +
            '  typeof: ' +
            typeof value
        );
      }
    }
  );
  SolarEngine.fastFetchRemoteConfigWithKey(
    'key_number',
    (value: object | null) => {
      if (value != null) {
        log(
          'fastFetchRemoteConfigWithKey, key_number: ' +
            value +
            '  typeof: ' +
            typeof value
        );
      }
    }
  );

  SolarEngine.fastFetchRemoteConfigWithKey(
    'key_boolean',
    (value: object | null) => {
      if (value != null) {
        log(
          'fastFetchRemoteConfigWithKey, key_boolean: ' +
            value +
            '  typeof: ' +
            typeof value
        );
      }
    }
  );
  SolarEngine.fastFetchRemoteConfigWithKey(
    'key_object',
    (value: object | null) => {
      if (value != null) {
        const key_objectValue = value as {
          name: string;
          hobbies: string[];
          age: number;
        };
        if (key_objectValue && typeof key_objectValue === 'object') {
          const nameValue = key_objectValue.name;
          const ageValue = key_objectValue.age;
          const hobbies = key_objectValue.hobbies;
          log('fastFetchRemoteConfigWithKey, nameValue: ' + nameValue);
          log('fastFetchRemoteConfigWithKey, ageValue: ' + ageValue);
          log('fastFetchRemoteConfigWithKey, hobbies: ' + hobbies);
        } else {
          console.warn(
            'key_objectValue is undefined or not an object',
            key_objectValue
          );
        }
      }
    }
  );

  SolarEngine.asyncFetchRemoteConfig((value: Object | null) => {
    if (value != null) {
      log(
        'asyncFetchRemoteConfig, JSON.stringify result: ' +
          JSON.stringify(value)
      );
      // const nameValue = value.name; // 使用点语法
      // const ageValue = value['hobbies']; // 使用下标访问
      const typedValue = value as {
        key_string: string;
        key_boolean: boolean;
        key_object: object;
        key_number: number;
      };
      log('asyncFetchRemoteConfig, key_string: ' + typedValue.key_string);
      log('asyncFetchRemoteConfig, key_boolean: ' + typedValue.key_boolean);
      log('asyncFetchRemoteConfig, key_number: ' + typedValue.key_number);

      const key_objectValue = typedValue.key_object as {
        name: string;
        hobbies: string[];
        age: number;
      };
      if (key_objectValue && typeof key_objectValue === 'object') {
        const nameValue = key_objectValue.name;
        const ageValue = key_objectValue.age;
        const hobbies = key_objectValue.hobbies;
        log('asyncFetchRemoteConfig, nameValue: ' + nameValue);
        log('asyncFetchRemoteConfig, ageValue: ' + ageValue);
        log('asyncFetchRemoteConfig, hobbies: ' + hobbies);
      } else {
        console.warn(
          'key_objectValue is undefined or not an object',
          key_objectValue
        );
      }
    }
  });

  SolarEngine.asyncFetchRemoteConfigWithKey(
    'key_object',
    (value: object | null) => {
      if (value != null) {
        const key_objectValue = value as {
          name: string;
          hobbies: string[];
          age: number;
        };
        if (key_objectValue && typeof key_objectValue === 'object') {
          const nameValue = key_objectValue.name;
          const ageValue = key_objectValue.age;
          const hobbies = key_objectValue.hobbies;
          log('asyncFetchRemoteConfigWithKey, nameValue: ' + nameValue);
          log('asyncFetchRemoteConfigWithKey, ageValue: ' + ageValue);
          log('asyncFetchRemoteConfigWithKey, hobbies: ' + hobbies);
        } else {
          console.warn(
            'key_objectValue is undefined or not an object',
            key_objectValue
          );
        }
      }
    }
  );
}
function _onPressButton() {
  log('Press button');
  _preInit();

  //ios
  requestTrackingAuthorization();
  updatePostbackConversionValue();
  Initiate();

  //android
  setOaid();
  setGaid();
  setChannel();
}
function _afterSDKInitialized() {
  log('_afterSDKInitialized invoked');

  setGDPRArea();
  retrieveAttribution();
  fetchDistinctId();
  setVisitorID();
  fetchVisitor();

  login();
  fetchAccount();
  logout();

  setSuperProperties;
  unsetSuperProperty;
  clearSuperProperties();

  retrievePresetProperties();
  setPreSetEventWithProperties();
  trackAdImpressionWithAttributes();
  trackAdClickWithAttributes();
  trackIAPWithAttributes();
  trackAppAttrWithAttributes();
  trackOrderWithAttributes();
  trackRegisterWithAttributes();
  trackLoginWithAttributes();
  trackCustomEvent();
  eventStart();
  eventEnd();
  trackFirstEvent();
  userPropertiesInit();
  userPropertiesUpdate();
  userPropertiesAdd();
  userPropertiesUnset();
  userPropertiesAppend();

  userPropertiesDelete();
  reportEventimmediately();

  trackAppReEngagement();
  appDeeplinkOpenURL();
}

let AndroidAppKey4Solarengine = 'a9f4882f4834592b'; //'e62fe50b80fc6e5c';//'3774454bfa22233a';//
let iOSAppKey4Solarengine = '07df077973a84ea7'; //1d91d62522d9a96d

function _preInit() {
  log('preInit');
  let appKey = '';
  if (Platform.OS === 'ios') {
    appKey = AndroidAppKey4Solarengine;
  } else if (Platform.OS === 'android') {
    appKey = iOSAppKey4Solarengine;
  }

  // SolarEngine.multiply(11,11);
  multiply(11, 11);
  preInit(appKey);
  SolarEngine.preInit(appKey);
}
function buildInitialConfig(): se_initial_config {
  let config: se_initial_config = {
    enableLog: true,
    enableDebug: false,
    enable2G: true,
    enableGDPR: true,
    enablePersonalizedAd: true,
    enableUserData: true,
    enableCoppa: true,
    enableKidsApp: true,
    enableDeferredDeeplink: true,
    // android: {
    //   metaAppId: 'place_your_meta_app_here',
    // },
    ios: {
      attAuthorizationWaitingInterval: 60,
      caid: '[{"version":"20220111","caid":"912ec803b2ce49e4a541068d495ab570"},{"version":"20211207","caid":"e332a76c29654fcb7f6e6b31ced090c7"}]',
    },
  };
  return config;
}
function buildRemoteConfig(): RemoteConfig {
  let remoteConfig: RemoteConfig = {
    enabled: true,
    mergeType: RemoteConfigMergeType.User,
    customIDProperties: { name: 'name_value' },
    customIDEventProperties: { age: 28 },
    customIDUserProperties: { key: 'value' },
  };
  return remoteConfig;
}
function buildAttribution(): attribution {
  const handleAttribution: attribution = (
    code: number,
    attributionInfo?: AttributionInfo
  ) => {
    log('attribution code: ' + code);
    if (code === 0) {
      log('attributionInfo: ' + JSON.stringify(attributionInfo));
      if (attributionInfo) {
        log('channel_name: ' + attributionInfo.channel_name);
        log('attribution_time: ' + attributionInfo.attribution_time);
        if (attributionInfo.re_data) {
          log('re_data.install_time: ' + attributionInfo.re_data.install_time);
          log(
            're_data.attribution_time: ' +
              attributionInfo.re_data.attribution_time
          );
        } else {
          log('re_data: is null');
        }
      }
    }
  };
  return handleAttribution;
}
function buildDeeplinkResponse(): deeplink {
  const handleDeepLink: deeplink = (
    code: number,
    deepLinkInfo?: DeepLinkInfo
  ) => {
    if (code === 0) {
      if (deepLinkInfo) {
        log('deepLinkInfo.sedpLink: ' + deepLinkInfo.sedpLink);
      }
    }
  };
  return handleDeepLink;
}
function buildDeferredDeeplinkResponse(): deferredDeeplink {
  const handleDeferredDeeplink: deferredDeeplink = (
    code: number,
    deferreddeeplink?: DeferredDeepLinkInfo
  ) => {
    if (code === 0) {
      if (deferreddeeplink) {
        log('deferreddeeplink.sedpLink: ' + deferreddeeplink.sedpLink);
      }
    }
  };
  return handleDeferredDeeplink;
}

async function Initiate() {
  log('Initiate');

  let appKey = '';
  if (Platform.OS === 'ios') {
    appKey = iOSAppKey4Solarengine;
  } else if (Platform.OS === 'android') {
    appKey = AndroidAppKey4Solarengine;
  }

  let config: se_initial_config = buildInitialConfig();
  let remoteConfig: RemoteConfig = buildRemoteConfig();
  let attribution: attribution = buildAttribution();
  let deeplink: deeplink = buildDeeplinkResponse();
  let deferredDeeplink: deferredDeeplink = buildDeferredDeeplinkResponse();

  let initiateOptions: SolarEngineInitiateOptions = {
    config: config,
    remoteConfig: remoteConfig,
    attribution: attribution,
    deeplink: deeplink,
    deferredDeeplink: deferredDeeplink,
  };
  SolarEngine.initialize(
    appKey,
    initiateOptions,
    (result: InitiateCompletionInfo) => {
      log('SolarEngine SDK Initiate result: ' + JSON.stringify(result));
      if (result.success) {
        Alert.alert('SDK Initiate Complete!');
        //Now you can report event via relevant api
      }
      _afterSDKInitialized();
    }
  );
}

function setGDPRArea() {
  SolarEngine.setGDPRArea(true);
}
function retrieveAttribution() {
  let attribution: AttributionInfo | null = SolarEngine.retrieveAttribution();
  log('attribution: ' + JSON.stringify(attribution));

  if (attribution != null) {
    log('channel_id:' + attribution.channel_id);
    log('channel_name:' + attribution.channel_name);
    log('attribution_time:' + attribution.attribution_time);
  } else {
    log('attribution is null');
  }
}

function fetchDistinctId() {
  let distinctId = SolarEngine.fetchDistinctId();
  log('distinctId: ' + distinctId);
}
function setVisitorID() {
  let visitorID: string = 'your visitor id';
  SolarEngine.setVisitorID(visitorID);
}

function fetchVisitor() {
  let visitorID = SolarEngine.fetchVisitor();
  log('visitorID: ' + visitorID);
}

function login() {
  let accountID: string = 'your account id';
  SolarEngine.login(accountID);
}

function logout() {
  SolarEngine.logout();
}

function fetchAccount() {
  let accountID = SolarEngine.fetchAccount();
  log('accountID: ' + accountID);
}

function setSuperProperties() {
  let superProperties: Object = {};
  SolarEngine.setSuperProperties(superProperties);
}

function unsetSuperProperty() {
  let key: string = 'your_key';
  SolarEngine.unsetSuperProperty(key);
}

function clearSuperProperties() {
  SolarEngine.clearSuperProperties();
}

function retrievePresetProperties() {
  let presetProperties = SolarEngine.retrievePresetProperties();
  let type = typeof presetProperties;
  log('retrievePresetProperties type: ' + type);
  log('retrievePresetProperties: ' + JSON.stringify(presetProperties));

  const object = presetProperties as {
    _package_name: string;
    _app_name: string;
    _screen_height: number;
  };
  log('_package_name:' + object._package_name);
  log('_app_name:' + object._app_name);
  log('_screen_height:' + object._screen_height);
}

function setPreSetEventWithProperties() {
  let eventType: PresetEventType =
    PresetEventType.START | PresetEventType.INSTALL | PresetEventType.END;

  SolarEngine.setPreSetEventWithProperties(eventType);
}
function trackAdImpressionWithAttributes() {
  let attribute: SEAdImpressionEventAttribute = {
    adNetworkPlatform: 'AdNetwork platform',
    adType: AdType.Banner,
    adNetworkAppID: 'AdNetwork appid',
    adNetworkPlacementID: 'AdNetwork placementid',
    mediationPlatform: 'mediation platform',
    currency: 'USD',
    ecpm: 1.234,
    rendered: true,
    customProperties: { customProperties: 'adimp customProperties value' },
  };
  SolarEngine.trackAdImpressionWithAttributes(attribute);
}
function trackAdClickWithAttributes() {
  let attribute: SEAdClickEventAttribute = {
    adNetworkPlatform: 'AdNetwork platform',
    adType: AdType.Interstitial,
    adNetworkPlacementID: 'AdNetwork placementid',
    mediationPlatform: 'mediation platform',
    customProperties: { customProperties: 'adclick customProperties value' },
  };
  SolarEngine.trackAdClickWithAttributes(attribute);
}
function trackIAPWithAttributes() {
  let attribute: SEIAPEventAttribute = {
    productID: 'product id',
    productName: 'product name',
    productCount: 3,
    orderId: 'order id',
    payAmount: 3.14,
    currency: 'USD',
    // const Alipay    = "alipay";
    // const Weixin    = "weixin";
    // const ApplePay  = "applepay";
    // const Paypal    = "paypal";
    payType: Paypal,
    // None        = 0,
    // Success     = 1,
    // Failed      = 2,
    // Restored    = 3
    payStatus: SEIAPStatus.Success,
    failReason: '',
    customProperties: { customProperties: 'iap customProperties value' },
  };
  SolarEngine.trackIAPWithAttributes(attribute);
}
function trackAppAttrWithAttributes() {
  let attribute: SEAppAttrEventAttribute = {
    adNetwork: 'toutiao',
    subChannel: '103300',
    adAccountID: '1655958321988611',
    adAccountName: 'xxx科技全量18',
    adCampaignID: '1680711982033293',
    adCampaignName: '冲冲冲计划157-1024',
    adOfferID: '1685219082855528',
    adOfferName: '冲冲冲单元406-1024',
    adCreativeID: '1680128668901378',
    adCreativeName: '自动创建20210901178921',
    attributionPlatform: '广告监测平台xxx',
    customProperties: { customProperties: 'app attr customProperties value' },
  };
  SolarEngine.trackAppAttrWithAttributes(attribute);
}
function trackOrderWithAttributes() {
  let attribute: SEOrderEventAttribute = {
    orderID: 'order id',
    payAmount: 3.1415926,
    currency: 'USD',
    payType: Paypal,
    status: 'success',
    customProperties: { customProperties: 'order customProperties value' },
  };
  SolarEngine.trackOrderWithAttributes(attribute);
}
function trackRegisterWithAttributes() {
  let attribute: SERegisterEventAttribute = {
    registerType: 'WeChat',
    registerStatus: 'success',
    customProperties: { customProperties: 'register customProperties value' },
  };
  SolarEngine.trackRegisterWithAttributes(attribute);
}
function trackLoginWithAttributes() {
  let attribute: SELoginEventAttribute = {
    loginType: 'WeChat',
    loginStatus: 'failed',
    customProperties: { customProperties: 'login customProperties value' },
  };
  SolarEngine.trackLoginWithAttributes(attribute);
}
function trackCustomEvent() {
  let eventName = 'fake_key_name';
  let customProperties = { customProperties: 'customProperties value' };
  let preProperties = {
    trackCustomEvent_key: ' trackCustomEvent_properties_singleValue',
  };
  SolarEngine.trackCustomEvent(eventName, customProperties, preProperties);
}
function eventStart() {
  let eventName = 'time_event_name';
  SolarEngine.eventStart(eventName);
}
function eventEnd() {
  let eventName = 'time_event_name';
  SolarEngine.eventEnd(eventName);
}
function trackFirstEvent() {
  let firstCheckId = 'login first check id';
  let attribute: SELoginEventAttribute = {
    loginType: 'WeChat',
    loginStatus: 'failed',
    customProperties: { customProperties_key: 'login customProperties value' },
  };
  SolarEngine.trackFirstEvent(firstCheckId, attribute);

  let customCheckId = 'custom first check id';
  let customAttribute: SECustomEventAttribute = {
    eventName: 'dummy_custom_event_name',
    customProperties: { preProperties_key: 'custom customProperties value' },
    preProperties: { preProperties_key: 'custom customProperties value' },
  };
  SolarEngine.trackFirstEvent(customCheckId, customAttribute);
}

function userPropertiesInit() {
  let properties = { properties_key: ' properties value' };
  SolarEngine.userPropertiesInit(properties);
}
function userPropertiesUpdate() {
  let properties = { properties_key: ' properties value' };
  SolarEngine.userPropertiesUpdate(properties);
}
function userPropertiesAdd() {
  let map = new Map<string, number>();
  map.set('key1', 1.14);
  map.set('key2', 2.14);
  map.set('key3', 3.14);

  SolarEngine.userPropertiesAdd(map);
}
function userPropertiesUnset() {
  let keys: Array<string> = ['key_name1', 'key_name2', 'key_name3'];
  SolarEngine.userPropertiesUnset(keys);
}
function userPropertiesAppend() {
  let properties = { append_key: 'append value' };
  SolarEngine.userPropertiesAppend(properties);
}

function userPropertiesDelete() {
  let type: SEUserDeleteType = SEUserDeleteType.ByVisitorId;
  SolarEngine.userPropertiesDelete(type);
}
function reportEventimmediately() {
  SolarEngine.reportEventimmediately();
}

function trackAppReEngagement() {
  let customProperties: Object = {};
  SolarEngine.trackAppReEngagement(customProperties);
}

function appDeeplinkOpenURL() {
  let urlString: string = 'https://your_deeplink_url_dummy';
  SolarEngine.appDeeplinkOpenURL(urlString);
}
/************** iOS *****************/
function requestTrackingAuthorization() {
  log('requestTrackingAuthorization invoked');

  let completion: requestTrackingAuthorizationCompletion = (
    status: ATTrackingManagerAuthorizationStatus
  ) => {
    if (status === ATTrackingManagerAuthorizationStatus.Restricted) {
    }
    log('requestTrackingAuthorizationCompletion status: ' + status);
  };
  SolarEngine.requestTrackingAuthorization(completion);
}

function updatePostbackConversionValue() {
  let conversionValue: number = 5;
  let coarseValue: SKAdNetworkCoarseType = SKAdNetworkCoarseType.High;
  let lockWindow: Boolean = false;
  let promise = SolarEngine.updatePostbackConversionValue(
    conversionValue,
    coarseValue,
    lockWindow
  );
  promise.then((error: Object | null) => {
    log('updatePostbackConversionValue error: ' + JSON.stringify(error));
  });
}

/************** Android *****************/
function setOaid() {
  let oaid: string = 'your oaid';
  SolarEngine.setOaid(oaid);
}
function setGaid() {
  let gaid: string = 'your gaid';
  SolarEngine.setGaid(gaid);
}
function setChannel() {
  let channel: string = 'your android apk channel';
  SolarEngine.setChannel(channel);
}

function log(str: string) {
  console.log('[SolarEngine Example]: ' + str);
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
