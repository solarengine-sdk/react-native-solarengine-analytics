import type { AttributionCallback } from './types/attribution';

export type se_initial_config = {
  //Whether to enable local debugging logs, the default is not enabled.
  enableLog?: boolean;

  //Whether to enable Debug mode, the default is not enabled. Before using it, please check XXX.
  enableDebug?: boolean;

  //Whether to report events when on a 2G network, the default is not to report.
  enable2G?: boolean;

  //If your application operates in the European Union region, it needs to comply with the regulations of the EU privacy protection law (regarding GDPR). Please be sure to set isGDPRArea(true) when the user refuses to collect sensitive device information. The default is to collect.
  enableGDPR?: boolean;

  //If your application needs to comply with the Children's Online Privacy Protection Act (COPPA) regulations, set setCoppaEnabled = true.
  enableCoppa?: boolean;

  //If your application is targeted at children under the age of 13, it needs to be marked as a Kids App and set setKidsAppEnabled = true.
  enableKidsApp?: boolean;

  //Whether to enable the deferred Deeplink, the default is NO (closed).
  enableDeferredDeeplink?: boolean;

  /************** Shared switches (supported by at least two platforms) *****************/
  //Whether to enable attribution service (incl. deeplink / deferred deeplink). Default true.
  enableAttribution?: boolean;
  //Whether to enable analytics service (A/B testing, online params). Default true. If both this and enableAttribution are false, SDK reports nothing.
  enableAnalytics?: boolean;

  /************** Shared data collection switches (supported by at least two platforms, default true) *****************/
  //Collect device language.
  enableLanguage?: boolean;
  //Collect device locale/region.
  enableLocale?: boolean;
  //Collect device timezone.
  enableTimeZone?: boolean;
  //Collect screen width/height.
  enableScreenWH?: boolean;
  //Collect screen density. Android and Harmony.
  enableDensity?: boolean;
  //Collect network status.
  enableNetworkType?: boolean;
  //Collect User Agent.
  enableUA?: boolean;
  //Collect IPv6 address.
  enableIPV6?: boolean;
  //Collect OAID. Android and Harmony.
  enableOAID?: boolean;

  /************** Android only, if need *****************/
  android?: {
    //If you need to use meta attribution, set the meta appid here.
    metaAppId?: string;

    //If your application operates in the European Union region and is promoted on Google, be sure to pass the result of the user's opinion on whether Google is allowed to use their data for personalized advertising into this attribute to ensure that you comply with Google's new policy on soliciting opinions from EU users.
    enablePersonalizedAd?: boolean;
    //If your application operates in the European Union region and is promoted on Google, be sure to pass the result of the user's opinion on whether they agree to send their data to Google into this attribute to ensure that you comply with Google's new policy on soliciting opinions from EU users.
    enableUserData?: boolean;

    //Whether to enable IMEI collection. Android only. Default true.
    isImeiEnabled?: boolean;
    //Whether to enable Android ID collection. Android only. Default true.
    isAndroidIDEnabled?: boolean;
    //Whether to support multi-process. Android only.
    supportMultiProcess?: boolean;
    //Whether to disable OAID retry. Android only.
    withDisableOAIDRetry?: boolean;
    //Whether to disable GAID retry. Android only. SDK Builder method name is witDisableGAIDRetry (typo, missing 'h').
    withDisableGAIDRetry?: boolean;
  };

  harmony?: {
    authorizationTimeout?: number;
    //Collect ODID. Harmony only.
    enableODID?: boolean;
    //Collect AAID. Harmony only.
    enableAAID?: boolean;
  };

  /************** iOS only, if need *****************/
  ios?: {
    attAuthorizationWaitingInterval?: number;
    caid?: string;
    // iOS only (overseas SDK). Enables ODM info attribution for Google iOS campaigns. Default false. Not supported on the CN SDK.
    enableODMInfo?: boolean;
  };
};

declare type CustomDomain = {
  enabled: boolean;
  receiverDomain: string;
  ruleDomain?: string;
  receiverTcpHost?: string;
  ruleTcpHost?: string;
  gatewayTcpHost?: string;
};

declare type InitiateCompletionInfo = {
  success: boolean;
  errorCode: number | undefined;
  message: string | undefined;
};

declare type DeepLinkInfo = {
  sedpLink: string;
  turlId: string;
  from: string;
  customParams?: Object;
};

declare type DeferredDeepLinkInfo = {
  sedpLink: string;
  turlId: string;
  sedpUrlscheme: string;
};

export enum RemoteConfigMergeType {
  User = 1,
  Cache = 2,
}
declare type RemoteConfig = {
  enabled: boolean;
  mergeType?: RemoteConfigMergeType;
  customIDProperties?: Object;
  customIDEventProperties?: Object;
  customIDUserProperties?: Object;
};

declare type SolarEngineInitiateOptions = {
  config?: se_initial_config;
  remoteConfig?: RemoteConfig;
  attribution?: attribution;
  deeplink?: deeplink;
  deferredDeeplink?: deferredDeeplink;
  customDomain?: CustomDomain;
};

type deeplink = (code: number, deepLinkInfo?: DeepLinkInfo) => void;
type deferredDeeplink = (
  code: number,
  deferredDeepLinkInfo?: DeferredDeepLinkInfo
) => void;

type attribution = AttributionCallback;
type requestTrackingAuthorizationCompletion = (
  status: ATTrackingManagerAuthorizationStatus
) => void;

export enum ATTrackingManagerAuthorizationStatus {
  NotDetermined = 0,
  Restricted = 1,
  Denied = 2,
  Authorized = 3,
  SystemError = 999,
}

export type {
  SolarEngineInitiateOptions,
  RemoteConfig,
  InitiateCompletionInfo,
  deeplink,
  deferredDeeplink,
  attribution,
  requestTrackingAuthorizationCompletion,
  DeepLinkInfo,
  DeferredDeepLinkInfo,
  CustomDomain,
};
