import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;

  // SDK Initiate
  preInit(appKey: string): void;
  initialize(
    appKey: string,
    config: Object,
    remoteConfig: Object,
    customDomain: Object
  ): void;
  setReactNativeBridgeVersion(version: string): void;
  registerInitiateComplete(callback: (code: number) => void): void;
  registerAttribution(callback: (result: Object) => void): void;
  registerDeeplink(callback: (result: Object) => void): void;
  registerDeferredDeeplink(callback: (result: Object) => void): void;

  // Attribution
  retrieveAttribution(): Object | null;

  // DistinctId
  fetchDistinctId(): string;

  // VisitorID
  setVisitorID(visitorID: string): void;
  fetchVisitor(): string;

  // AccountID
  login(accountID: string): void;
  fetchAccount(): string;
  logout(): void;

  // SuperProperties
  setSuperProperties(properties: Object): void;
  unsetSuperProperty(key: string): void;
  clearSuperProperties(): void;

  // Preset Properties
  retrievePresetProperties(): Object;
  setPresetProperties(eventType: string, properties?: Object): void;

  // Predefined Events
  trackAdImpressionWithAttributes(attributes: Object): void;
  trackAdClickWithAttributes(attributes: Object): void;
  trackIAPWithAttributes(attributes: Object): void;
  trackAppAttrWithAttributes(attributes: Object): void;
  trackOrderWithAttributes(attributes: Object): void;
  trackRegisterWithAttributes(attributes: Object): void;
  trackLoginWithAttributes(attributes: Object): void;

  // Custom Event
  trackCustomEvent(
    eventName: string,
    customProperties?: Object,
    preProperties?: Object
  ): void;

  // Duration Event
  eventStart(eventName: string): void;
  eventEnd(eventName: string, properties?: Object): void;

  // First-Time Event
  trackFirstEvent(firstCheckId: string, eventAttribute: Object): void;

  // User Properties
  userPropertiesInit(properties: Object): void;
  userPropertiesUpdate(properties: Object): void;
  userPropertiesAdd(properties: Object): void;
  userPropertiesUnset(keys: Array<string>): void;
  userPropertiesAppend(properties: Object): void;
  userPropertiesDelete(deleteType: number): void;

  // Report Event
  reportEventimmediately(): void;

  // Deep Linking
  trackAppReEngagement(properties: Object): void;
  appDeeplinkOpenURL(urlString: string): void;

  // Remote Config
  setDefaultConfig(configs: Array<Object>): void;
  setRemoteConfigEventProperties(properties: Object): void;
  setRemoteConfigUserProperties(properties: Object): void;
  fastFetchRemoteConfigWithKey(
    key: string,
    callback: (value?: Object) => void
  ): void;
  fastFetchRemoteConfig(callback: (configs?: Object) => void): void;
  asyncFetchRemoteConfigWithKey(
    key: string,
    callback: (value?: Object) => void
  ): void;
  asyncFetchRemoteConfig(callback: (configs?: Object) => void): void;

  // GDPR
  setGDPRArea(isGDPRArea: boolean): void;

  // iOS Specific
  requestTrackingAuthorization(callback: (status: number) => void): void;
  updatePostbackConversionValue(
    type: number,
    conversionValue: number,
    coarseValue: string,
    lockWindow: boolean,
    callback: (error: Object) => void
  ): void;

  // Android Specific
  setOaid(oaid?: string): void;
  setGaid(gaid: string): void;
  setChannel(channel: string): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'SolarengineAnalysisReactNative'
);
