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

  //If your application operates in the European Union region and is promoted on Google, be sure to pass the result of the user's opinion on whether Google is allowed to use their data for personalized advertising into this attribute to ensure that you comply with Google's new policy on soliciting opinions from EU users.
  enablePersonalizedAd?: boolean;

  //If your application operates in the European Union region and is promoted on Google, be sure to pass the result of the user's opinion on whether they agree to send their data to Google into this attribute to ensure that you comply with Google's new policy on soliciting opinions from EU users.
  enableUserData?: boolean;

  //If your application needs to comply with the Children's Online Privacy Protection Act (COPPA) regulations, set setCoppaEnabled = true.
  enableCoppa?: boolean;

  //If your application is targeted at children under the age of 13, it needs to be marked as a Kids App and set setKidsAppEnabled = true.
  enableKidsApp?: boolean;

  //Whether to enable the deferred Deeplink, the default is NO (closed).
  enableDeferredDeeplink?: boolean;

  /************** Android only, if need *****************/
  android?: {
    //If you need to use meta attribution, set the meta appid here.
    metaAppId?: string;
  };

  /************** iOS only, if need *****************/
  ios?: {
    attAuthorizationWaitingInterval?: number;
    caid?: string;
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
