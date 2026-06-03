import {
  AttributionListener,
  booleanItem,
  ConfigItem,
  DeeplinkInfo,
  DeepLinkListener,
  DeferredDeepLinkListener,
  InitSDKListener,
  jsonItem,
  numberItem,
  RemoteConfig,
  RemoteConfigManager,
  safeBoxingConfigItem,
  SEAdClickEventModel,
  SEAdImpEventModel,
  SEAppReEngagementModel,
  SEAttributionEventModel,
  SECustomEventModel,
  SELoginEventModel,
  SEOrderEventModel,
  SEPurchaseEventModel,
  SERegisterEventModel,
  SeSdkSource,
  SEUserDeleteType,
  SolarEngineConfig,
  SolarEngineManager,
  stringItem
} from '@solarengine/core';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TurboModule, TurboModuleContext } from '@rnoh/react-native-openharmony';

export const _log: boolean = true;

export const _SolarEngineLog: string = "[SeSDKRNBridge]:";

const LOG_DOMAIN = 0x0000;
const LOG_TAG = 'SeSDKRN';

function logInfo(message: string) {
  if (_log) {
    hilog.info(LOG_DOMAIN, LOG_TAG, '%{public}s', message);
  }
}

function logError(message: string) {
  hilog.error(LOG_DOMAIN, LOG_TAG, '%{public}s', message);
}

interface SolarEngineNativeResult {
  reactnative_code: number;
  reactnative_data?: Object;
}

export class SolarengineAnalysisReactNative extends TurboModule {
  constructor(ctx: TurboModuleContext) {
    super(ctx);
  }


  getName(): string {
    logInfo(`${_SolarEngineLog} getName`);
    return "SolarengineAnalysisReactNative";
  }

  multiply(a: number, b: number): number {
    logInfo(`${_SolarEngineLog} multiply a=${a}, b=${b}`);
    return a * b;
  }

  preInit(appkey: string) {
    if (_log) {
      console.log(_SolarEngineLog, "preInit", appkey)
    }
    logInfo(`${_SolarEngineLog} preInit appkey=${appkey}`);
    try {
      SolarEngineManager.preInit(this.ctx.uiAbilityContext, appkey);
    } catch (error) {
      console.error(`${_SolarEngineLog} preInit failed:`, error);
      logError(`${_SolarEngineLog} preInit failed`);
    }
  }

  setReactNativeBridgeVersion(version: string) {
    if (_log) {
      console.log(`${_SolarEngineLog} setReactNativeBridgeVersion:${version}`);
    }
    logInfo(`${_SolarEngineLog} setReactNativeBridgeVersion:${version}`);
    try {
      const sdkSource = new SeSdkSource();
      sdkSource.subLibVersion = version;
      sdkSource.sdkType = "reactnative";
      SolarEngineManager.setSeSdkSource(sdkSource)
    } catch (error) {
      console.error(`${_SolarEngineLog} setReactNativeBridgeVersion failed:`, error);
      logError(`${_SolarEngineLog} setReactNativeBridgeVersion failed`);
    }
  }

  registerInitiateComplete(callback: (code: number) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "registerInitiateComplete")
    }
    logInfo(`${_SolarEngineLog} registerInitiateComplete`);
    try {
      let onInitListener: InitSDKListener = {
        onInitComplete: (code: number) => {
          if (_log) {
            console.log(_SolarEngineLog, "onInitComplete", code)
          }
          logInfo(`${_SolarEngineLog} onInitComplete code=${code}`);
          callback?.(code);
        }
      };
      SolarEngineManager.setInitSDKListener(onInitListener);
    } catch (error) {
      console.error(`${_SolarEngineLog} registerInitiateComplete failed:`, error);
      logError(`${_SolarEngineLog} registerInitiateComplete failed`);
    }
  }

  registerAttribution(callback: (result: Object) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "registerAttribution")
    }
    logInfo(`${_SolarEngineLog} registerAttribution`);
    try {
      let attributionListener: AttributionListener = {
        onAttributionSuccess: (attribution: Record<string, Object>) => {
          if (_log) {
            console.log(_SolarEngineLog, "onAttributionSuccess", JSON.stringify(attribution))
          }
          logInfo(`${_SolarEngineLog} onAttributionSuccess`);
          const result: SolarEngineNativeResult = {
            reactnative_code: 0,
            reactnative_data: attribution
          }
          callback?.(result);
        },
        onAttributionFailed: (errorCode: number) => {
          if (_log) {
            console.log(_SolarEngineLog, "onAttributionFailed: errorCode: ", errorCode)
          }
          logInfo(`${_SolarEngineLog} onAttributionFailed errorCode=${errorCode}`);
          const result: SolarEngineNativeResult = {
            reactnative_code: errorCode,
          }
          callback?.(result);
        }
      };
      SolarEngineManager.setAttributionListener(attributionListener);
    } catch (error) {
      console.error(`${_SolarEngineLog} registerAttribution failed:`, error);
      logError(`${_SolarEngineLog} registerAttribution failed`);
    }
  }

  registerDeeplink(callback: (result: Object) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "registerDeeplink")
    }
    logInfo(`${_SolarEngineLog} registerDeeplink`);
    try {
      const deepLinkListener: DeepLinkListener = {
        onReceived: (code: number, deeplinkInfo?: DeeplinkInfo) => {
          if (_log) {
            console.log(_SolarEngineLog, "onReceived", code, JSON.stringify(deeplinkInfo))
          }
          logInfo(`${_SolarEngineLog} onReceived code=${code}`);
          const result: SolarEngineNativeResult = {
            reactnative_code: code,
            reactnative_data: deeplinkInfo ?? []
          }
          console.log(_SolarEngineLog, "onReceived。 2222", code, JSON.stringify(result))
          callback?.(result);
        }
      };
      SolarEngineManager.setDeepLinkListener(deepLinkListener);
    } catch (error) {
      console.error(`${_SolarEngineLog} registerDeeplink failed:`, error);
      logError(`${_SolarEngineLog} registerDeeplink failed`);
    }
  }

  registerDeferredDeeplink(callback: (result: Object) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "registerDeferredDeeplink")
    }
    logInfo(`${_SolarEngineLog} registerDeferredDeeplink`);
    try {
      const delayDeepLinkListener: DeferredDeepLinkListener = {
        onReceivedSuccess: (attribution: Record<string, Object>) => {
          if (_log) {
            console.log(_SolarEngineLog, "onReceivedSuccess", JSON.stringify(attribution))
          }
          logInfo(`${_SolarEngineLog} onReceivedSuccess`);
          const result: SolarEngineNativeResult = {
            reactnative_code: 0,
            reactnative_data: attribution
          }
          callback?.(result);
        },
        onReceivedFailed: (errorCode: number) => {
          if (_log) {
            console.log(_SolarEngineLog, "onReceivedFailed: errorCode: ", errorCode)
          }
          logInfo(`${_SolarEngineLog} onReceivedFailed errorCode=${errorCode}`);
          const result: SolarEngineNativeResult = {
            reactnative_code: errorCode,
          }
          callback?.(result);
        }
      };
      SolarEngineManager.setDeferredDeepLinkListener(delayDeepLinkListener);

      //mock
      // setTimeout(() => {
      //   // 1. 创建空对象（ArkTS 允许）
      //   const mockData = {} as Record<string, Object>;
      //
      //   // 2. 逐个赋值（ArkTS 允许）
      //   mockData["sedp_link"] = "productDetail?productId=10086&channel=test&from=share";
      //   mockData["turl_id"] = "A7S92K1";
      //   mockData["sedp_urlscheme"] = "yourapp://open/deeplink";
      //
      //   // 3. 触发回调
      //   delayDeepLinkListener.onReceivedSuccess(mockData);
      //
      //   // 失败 Mock（注释上面，打开下面）
      //   // delayDeepLinkListener.onReceivedFailed(1106);
      // }, 500);

    } catch (error) {
      console.error(`${_SolarEngineLog} registerDeferredDeeplink failed:`, error);
    }
  }

  retrieveAttribution(): Object | null {
    if (_log) {
      console.log(_SolarEngineLog, "retrieveAttribution")
    }
    try {
      return SolarEngineManager.getAttribution();
    } catch (error) {
      console.error(`${_SolarEngineLog} retrieveAttribution failed:`, error);
      return null;
    }
  }

  initialize(appkey: string, config: object, rcConfig: object, customDomain: object) {
    if (_log) {
      console.log(`${_SolarEngineLog} initialize config:${JSON.stringify(config)} \n rcConfig: ${JSON.stringify(rcConfig)}`);
    }
    try {
      const solarEngineConfig = new SolarEngineConfig();
      const localConfig = config as Record<string, Object>;
      const harmonyConfig =
        localConfig[SolarEngineConfigConstant.Harmony] as Record<string, number> | undefined;

      solarEngineConfig.isDebugMode = config[SolarEngineConfigConstant.IsDebugModel];
      solarEngineConfig.logEnabled = config[SolarEngineConfigConstant.LogEnabled];
      solarEngineConfig.enableDeferredDeeplink = config[SolarEngineConfigConstant.EnableDelayDeeplink];
      if (
        harmonyConfig &&
          harmonyConfig[SolarEngineConfigConstant.AuthorizationTimeout] !== undefined
      ) {
        solarEngineConfig.authorizationTimeout = Number(
          harmonyConfig[SolarEngineConfigConstant.AuthorizationTimeout]
        );
      }
      solarEngineConfig.enable2GReporting = config[SolarEngineConfigConstant.Enable2G];
      solarEngineConfig.enableIPV6 = config[SolarEngineConfigConstant.EnableIPV6];


      if (rcConfig) {
        const rc = new RemoteConfig();
        rc.enable = rcConfig[SolarEngineConfigConstant.RCEnable];
        rc.mergeType = rcConfig[SolarEngineConfigConstant.RCMergeType];
        rc.customIDProperties =
          rcConfig[SolarEngineConfigConstant.RCCustomIDProperties] as Record<string, Object> || {};
        rc.customIDEventProperties =
          rcConfig[SolarEngineConfigConstant.RCCustomIDEventProperties] as Record<string, Object> || {};
        rc.customIDUserProperties =
          rcConfig[SolarEngineConfigConstant.RCCustomIDUserProperties] as Record<string, Object> || {};
        solarEngineConfig.remoteConfig = rc;
      }

      if (_log) {
        console.log(`${_SolarEngineLog} solarEngineConfig :${JSON.stringify(solarEngineConfig)}`);

      }
      SolarEngineManager.initialize(this.ctx.uiAbilityContext, appkey, solarEngineConfig);
    } catch (error) {
      console.error(`${_SolarEngineLog} initialize failed:`, error);
    }
  }

  setOaid(oaid: string) {
    if (_log) {
      console.log(_SolarEngineLog, "setOaId", oaid);
    }
    try {
      SolarEngineManager.setOaId(oaid);
    } catch (error) {
      console.error(`${_SolarEngineLog} setOaId failed:`, error);
    }
  }

  setChannel(channel: string) {
    if (_log) {
      console.log(_SolarEngineLog, "setChannel", channel);
    }
    try {
      SolarEngineManager.setChannel(channel);
    } catch (error) {
      console.error(`${_SolarEngineLog} setChannel failed:`, error);
    }
  }

  setVisitorID(visitor: string) {
    if (_log) {
      console.log(_SolarEngineLog, "setVisitorID", visitor);
    }
    try {
      SolarEngineManager.setVisitorID(visitor);
    } catch (error) {
      console.error(`${_SolarEngineLog} setVisitorID failed:`, error);
    }
  }

  login(accountId: string) {
    if (_log) {
      console.log(_SolarEngineLog, "login", accountId);
    }
    try {
      SolarEngineManager.login(accountId);
    } catch (error) {
      console.error(`${_SolarEngineLog} login failed:`, error);
    }
  }


  logout() {
    if (_log) {
      console.log(_SolarEngineLog, "logout");
    }
    try {
      SolarEngineManager.logout();
    } catch (error) {
      console.error(`${_SolarEngineLog} logout failed:`, error);
    }
  }

  setSuperProperties(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "setSuperProperties ", JSON.stringify(properties));
    }
    try {
      Object.keys(properties).forEach(key => {
        const value: Object = properties[key];
        SolarEngineManager.setSuperProperties(this.ctx.uiAbilityContext, key, value);
      });
    } catch (error) {
      console.error(`${_SolarEngineLog} setSuperProperties failed:`, error);
    }
  }

  unsetSuperProperty(publicKey: string): void {
    if (_log) {
      console.log(_SolarEngineLog, "unsetSuperProperty", publicKey);
    }
    try {
      SolarEngineManager.unsetSuperProperty(this.ctx.uiAbilityContext, publicKey);
    } catch (error) {
      console.error(`${_SolarEngineLog} unsetSuperProperty failed:`, error);
    }
  }

  clearSuperProperties(): void {
    if (_log) {
      console.log(_SolarEngineLog, "clearSuperProperties");
    }
    try {
      SolarEngineManager.clearSuperProperties(this.ctx.uiAbilityContext);
    } catch (error) {
      console.error(`${_SolarEngineLog} clearSuperProperties failed:`, error);
    }
  }

  retrievePresetProperties(callback: (properties: object) => void) {

    if (_log) {
      console.log(_SolarEngineLog, "getPresetProperties");
    }
    try {
      SolarEngineManager.getPresetProperties().then(result => {

        if (_log) {
          console.log(_SolarEngineLog, "getPresetProperties", JSON.stringify(result));
        }
        callback?.(result);
      });
    } catch (error) {
      callback?.([]);
      console.error(`${_SolarEngineLog} getPresetProperties failed:`, error);
    }
  }

  setPresetProperties(presetEventType: number, customProperties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "setPresetProperties", presetEventType, "   customProperties :",
        JSON.stringify(customProperties));
    }
    try {


      let properties = customProperties as Record<string, Object>;
      SolarEngineManager.setPresetEventProperties(presetEventType, properties);

      // switch (presetEventType) {
      //     case SEConstant.PresetEventTypeAppInstall:
      //         SolarEngineManager.setPresetEventProperties(SEPresetEventType.AppInstall, properties);
      //         break;
      //     case SEConstant.PresetEventTypeAppStart:
      //         SolarEngineManager.setPresetEventProperties(SEPresetEventType.AppStart, properties);
      //         break;
      //     case SEConstant.PresetEventTypeAppEnd:
      //         SolarEngineManager.setPresetEventProperties(SEPresetEventType.AppEnd, properties);
      //         break;
      //     case SEConstant.PresetEventTypeAppAll:
      //         SolarEngineManager.setPresetEventProperties(SEPresetEventType.All, properties);
      //         break;
      //     default:
      //         const typeNum = Number(presetEventType);
      //         if (!isNaN(typeNum)) {
      //             SolarEngineManager.setPresetEventProperties(typeNum, properties);
      //         }
      //         break;
      // }
    } catch (error) {
      console.error(`${_SolarEngineLog} setPresetProperties failed:`, error);
    }
  }


  trackAdImpressionWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackAdImpressionWithAttributes");
    }
    try {
      let impModel = new SEAdImpEventModel();
      impModel.adNetworkPlatform = properties[SEConstant.IAI_AdPlatform];
      impModel.mediationPlatform = properties[SEConstant.IAI_MediationPlatform];
      impModel.adType = properties[SEConstant.IAI_AdType];
      impModel.adNetworkAppID = properties[SEConstant.IAI_AdAppid];
      impModel.adNetworkADID = properties[SEConstant.IAI_AdId];
      impModel.ecpm = properties[SEConstant.IAI_AdEcpm];
      impModel.currencyType = properties[SEConstant.IAI_CurrencyType];
      impModel.isRenderSuccess = properties[SEConstant.IAI_IsRendered];
      const customProperties: Record<string, object> = properties[SEConstant.IAI_CustomProperties] || {};
      impModel.customProperties = customProperties;
      SolarEngineManager.trackAdImpression(impModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackAdImpressionWithAttributes failed:`, error);
    }
  }

  trackAdClickWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackAdClickWithAttributes", JSON.stringify(properties));
    }
    try {
      let clickEventModel = new SEAdClickEventModel();
      clickEventModel.adNetworkPlatform = properties[SEConstant.AdClick_AdPlatform];
      clickEventModel.mediationPlatform = properties[SEConstant.AdClick_MediationPlatform];
      clickEventModel.adType = properties[SEConstant.AdClick_AdType];
      clickEventModel.adNetworkADID = properties[SEConstant.AdClick_AdId];
      const customProperties: Record<string, Object> = properties[SEConstant.AdClick_CustomProperties] || {};
      clickEventModel.customProperties = customProperties;
      SolarEngineManager.trackAdClick(clickEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackAdClickWithAttributes failed:`, error);
    }
  }

  trackIAPWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackIAPWithAttributes", JSON.stringify(properties));
    }
    try {

      let purchaseEventModel = new SEPurchaseEventModel();
      purchaseEventModel.orderId = properties[SEConstant.IAP_OrderId];
      purchaseEventModel.payAmount = properties[SEConstant.IAP_Amount];
      purchaseEventModel.currencyType = properties[SEConstant.IAP_Currency];
      purchaseEventModel.payType = properties[SEConstant.IAP_PayType];
      purchaseEventModel.productId = properties[SEConstant.IAP_PID];
      purchaseEventModel.productName = properties[SEConstant.IAP_PName];
      purchaseEventModel.productNum = properties[SEConstant.IAP_PCount];
      purchaseEventModel.payStatus = properties[SEConstant.IAP_Paystatus];
      purchaseEventModel.failReason = properties[SEConstant.IAP_FailReason];
      const customProperties: Record<string, Object> = properties[SEConstant.IAP_CustomProperties] || {};
      purchaseEventModel.customProperties = customProperties;
      SolarEngineManager.trackPurchase(purchaseEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackIAPWithAttributes failed:`, error);
    }
  }

  trackOrderWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackOrderWithAttributes", JSON.stringify(properties));
    }
    try {
      const orderEventModel = new SEOrderEventModel();
      orderEventModel.orderId = properties[SEConstant.Order_ID];
      orderEventModel.payAmount = properties[SEConstant.Order_Pay_Amount];
      orderEventModel.currencyType = properties[SEConstant.Order_Currency_Type];
      orderEventModel.payType = properties[SEConstant.Order_Pay_Type];
      orderEventModel.status = properties[SEConstant.Order_Status];
      const customProperties: Record<string, Object> = properties[SEConstant.Order_CustomProperties] || {};
      orderEventModel.customProperties = customProperties;
      SolarEngineManager.trackOrder(orderEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackOrderWithAttributes failed:`, error);
    }
  }

  trackRegisterWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackRegisterWithAttributes", JSON.stringify(properties));
    }
    try {
      const registerEventModel = new SERegisterEventModel();
      registerEventModel.regType = properties[SEConstant.Register_Type];
      registerEventModel.status = properties[SEConstant.Register_Status];
      const customProperties: Record<string, Object> = properties[SEConstant.Register_CustomProperties] || {};
      registerEventModel.customProperties = customProperties;
      SolarEngineManager.trackAppRegister(registerEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackRegisterWithAttributes failed:`, error);
    }
  }

  trackLoginWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackLoginWithAttributes", JSON.stringify(properties));
    }
    try {
      const loginEventModel = new SELoginEventModel();
      loginEventModel.loginType = properties[SEConstant.Login_Type];
      loginEventModel.status = properties[SEConstant.Login_Status];
      const customProperties: Record<string, Object> = properties[SEConstant.Login_CustomProperties] || {};
      loginEventModel.customProperties = customProperties;
      SolarEngineManager.trackAppLogin(loginEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackLoginWithAttributes failed:`, error);
    }
  }

  trackAppAttrWithAttributes(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackAppAttrWithAttributes", JSON.stringify(properties));
    }
    try {

      let attributionEventModel = new SEAttributionEventModel();
      attributionEventModel.adNetwork = properties[SEConstant.AppAttr_Ad_Network];
      attributionEventModel.subChannel = properties[SEConstant.AppAttr_Sub_Channel];
      attributionEventModel.adAccountId = properties[SEConstant.AppAttr_Ad_Account_ID];
      attributionEventModel.adAccountName = properties[SEConstant.AppAttr_Ad_Account_Name];
      attributionEventModel.adCampaignId = properties[SEConstant.AppAttr_Ad_Campaign_ID];
      attributionEventModel.adCampaignName = properties[SEConstant.AppAttr_Ad_Campaign_Name];
      attributionEventModel.adOfferId = properties[SEConstant.AppAttr_Ad_Offer_ID];
      attributionEventModel.adOfferName = properties[SEConstant.AppAttr_Ad_Offer_Name];
      attributionEventModel.adCreativeId = properties[SEConstant.AppAttr_Ad_Creative_ID];
      attributionEventModel.adCreativeName = properties[SEConstant.AppAttr_Ad_Creative_Name];
      attributionEventModel.attributionPlatform = properties[SEConstant.AppAttr_AttributionPlatform];
      const customProperties: Record<string, Object> = properties[SEConstant.AppAttr_Ad_CustomProperties] || {};
      attributionEventModel.customProperties = customProperties;
      SolarEngineManager.trackAppAttribution(attributionEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackAppAttrWithAttributes failed:`, error);
    }
  }

  trackCustomEvent(customEventName: string, customProperties: object, preAttributes?: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackCustomEvent", JSON.stringify(customProperties));
    }
    try {
      const customEventModel = new SECustomEventModel();
      customEventModel.eventName = customEventName;
      customEventModel.customProperties = customProperties as Record<string, object>;
      if (preAttributes) {
        customEventModel.preProperties = preAttributes as Record<string, object>;
      }
      SolarEngineManager.trackCustom(customEventModel);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackCustomEvent failed:`, error);
    }
  }

  trackAppReEngagement(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackAppReEngagement", JSON.stringify(properties));
    }
    try {
      let model = new SEAppReEngagementModel();
      model.customProperties = properties as Record<string, object>;
      SolarEngineManager.trackAppReEngagement(model);
    } catch (error) {
      console.error(`${_SolarEngineLog} trackAppReEngagement failed:`, error);
    }
  }

  trackFirstEvent(firstCheckId: string, eventAttribute: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "trackFirstEvent", firstCheckId, JSON.stringify(eventAttribute));
    }
    try {
      const type: string = eventAttribute[SEConstant.First_INNER_TYPE];
      switch (type) {
        case SEConstant.First_Register_EVENT:
          const registerEventModel = new SERegisterEventModel();
          registerEventModel.regType = eventAttribute["registerType"];
          registerEventModel.status = eventAttribute["registerStatus"];
          registerEventModel.customProperties = eventAttribute[SEConstant.First_CustomProperties] || {};
          registerEventModel.checkId = firstCheckId;
          SolarEngineManager.trackFirstEvent(registerEventModel);
          break;
        case SEConstant.First_Custom_EVENT:
          const customEventModel = new SECustomEventModel();
          customEventModel.eventName = eventAttribute[SEConstant.First_Custom_EVENT_NAME];
          customEventModel.checkId = firstCheckId;
          customEventModel.preProperties = eventAttribute[SEConstant.First_Custom_EVENT_PRE];
          customEventModel.customProperties = eventAttribute[SEConstant.First_Custom_EVENT_CUSTOM] || {};
          SolarEngineManager.trackFirstEvent(customEventModel);
          break;
      }
    } catch (error) {
      console.error(`${_SolarEngineLog} trackFirstEvent failed:`, error);
    }
  }

  userPropertiesInit(userProperties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesInit", JSON.stringify(userProperties));
    }
    try {
      SolarEngineManager.userInit(userProperties as Record<string, object>);
    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesInit failed:`, error);
    }
  }

  userPropertiesUpdate(userProperties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesUpdate", JSON.stringify(userProperties));
    }
    try {
      SolarEngineManager.userUpdate(userProperties as Record<string, object>);
    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesUpdate failed:`, error);
    }
  }

  userPropertiesAdd(userProperties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesAdd", JSON.stringify(userProperties));
    }
    try {
      SolarEngineManager.userAdd(userProperties as Record<string, number>);
    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesAdd failed:`, error);
    }
  }

  userPropertiesAppend(userProperties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesAppend", JSON.stringify(userProperties));
    }
    try {
      SolarEngineManager.userAppend(userProperties as Record<string, number>);
    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesAppend failed:`, error);
    }
  }

  userPropertiesUnset(keys: Array<string>): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesUnset", JSON.stringify(keys));
    }
    try {
      SolarEngineManager.userUnset(keys);
    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesUnset failed:`, error);
    }
  }

  userPropertiesDelete(deleteType: number): void {
    if (_log) {
      console.log(_SolarEngineLog, "userPropertiesDelete", deleteType);
    }
    try {
      switch (deleteType) {
        case 1:
          SolarEngineManager.userDelete(SEUserDeleteType.DELETE_BY_ACCOUNTID);
          break;
        case 2:
          SolarEngineManager.userDelete(SEUserDeleteType.DELETE_BY_VISITORID);
          break;
      }


    } catch (error) {
      console.error(`${_SolarEngineLog} userPropertiesDelete failed:`, error);
    }
  }

  eventStart(eventName: string): void {
    if (_log) {
      console.log(_SolarEngineLog, "eventStart", eventName);
    }
    try {
      SolarEngineManager.eventStart(eventName);
    } catch (error) {
      console.error(`${_SolarEngineLog} eventStart failed:`, error);
    }
  }

  eventEnd(eventName: string, attributes: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "eventEnd", eventName, JSON.stringify(attributes));
    }
    try {
      SolarEngineManager.eventFinish(eventName, attributes as Record<string, object>);
    } catch (error) {
      console.error(`${_SolarEngineLog} eventEnd failed:`, error);
    }
  }

  reportEventimmediately(): void {
    if (_log) {
      console.log(_SolarEngineLog, "reportEventimmediately");
    }
    try {
      SolarEngineManager.reportEventImmediately();
    } catch (error) {
      console.error(`${_SolarEngineLog} reportEventimmediately failed:`, error);
    }
  }

  fetchDistinctId(callback: (id: string) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "getDistinctId");
    }
    try {
      SolarEngineManager.getDistinctId().then(result => {
        if (_log) {
          console.log(_SolarEngineLog, "getDistinctId", result);
        }
        callback?.(result);
      })
    } catch (error) {
      callback?.("");
      console.error(`${_SolarEngineLog} getDistinctId failed:`, error);
    }
  }

  fetchVisitor(callback: (id: string) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "getVisitorID");
    }
    try {
      SolarEngineManager.getVisitorID().then(result => {
        if (_log) {
          console.log(_SolarEngineLog, "getVisitorID", result);
        }
        callback?.(result);
      })
    } catch (error) {
      console.error(`${_SolarEngineLog} getVisitorID failed:`, error);
    }

  }

  fetchAccount(): string {
    if (_log) {
      console.log(_SolarEngineLog, "fetchAccount");
    }
    try {
      return SolarEngineManager.getAccountID();
    } catch (error) {
      console.error(`${_SolarEngineLog} fetchAccount failed:`, error);
      return "";
    }
  }

  appDeeplinkOpenURL(url: string): void {
    if (_log) {
      console.log(_SolarEngineLog, "appDeeplinkOpenURL", url);
    }
    try {
      SolarEngineManager.appDeeplinkOpenURI(url);
    } catch (error) {

      console.error(`${_SolarEngineLog} appDeeplinkOpenURL failed:`, error);
    }
  }

  authorizationCompleted() {
    if (_log) {
      console.log(_SolarEngineLog, "authorizationCompleted");
    }
    try {
      SolarEngineManager.authorizationCompleted();
    } catch (error) {
      console.error(`${_SolarEngineLog} authorizationCompleted failed:`, error);
    }
  }

  setInternalLogEnabled(enabled: boolean) {
    if (_log) {
      console.log(_SolarEngineLog, "setInternalLogEnabled", enabled);
    }
    try {
      SolarEngineManager.setInternalLogEnabled(enabled);
    } catch (error) {
      console.error(`${_SolarEngineLog} setInternalLogEnabled failed:`, error);
    }
  }

  requestPermissionsFromUser(callback: (code: number) => void) {
    try {
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(this.ctx.uiAbilityContext, ["ohos.permission.APP_TRACKING_CONSENT"])
        .then((data) => {
          if (data.authResults[0] == 0) {
            if (_log) {
              console.log(_SolarEngineLog, 'request permission success');
            }
            callback?.(0);
          } else {
            if (_log) {
              console.log(_SolarEngineLog, 'user rejected');
            }
            callback?.(1);
          }
        })
        .catch((err: BusinessError) => {
          callback?.(999);
          if (_log) {
            console.log(_SolarEngineLog, `request permission failed, error: ${err.code} ${err.message}`);
          }
        })
    } catch (err) {
      callback?.(999);
      console.log(_SolarEngineLog, `request permission failed, error: ${err.code} ${err.message}`);

    }

  }


  setDefaultConfig(config: object): void {

    if (_log) {
      console.log(_SolarEngineLog, "setRemoteDefaultConfig", JSON.stringify(config));
    }
    try {
      // const remoteDefaultConfigJsonObject = SEOpenHarmonyProxy.parseJsonStrict(defaultConfig);
      let _defaultConfig: Array<ConfigItem> = new Array();
      Object.keys(config as Record<string, Object>).forEach(key => {
        const value: Record<string, Object> = config[key];

        let nameItem: string = value[SERCConstant.NAME].toString();
        let valueItem: object = value[SERCConstant.VALUE];

        let type = value[SERCConstant.TYPE];
        if (_log) {
          console.log(`${_SolarEngineLog} setRemoteDefaultConfig: Item  ${valueItem}: ${nameItem} :${type}`);
        }

        switch (type) {
          case 1:
            let item1 = stringItem(nameItem, valueItem.toString());
            safeBoxingConfigItem(_defaultConfig, item1);

            break;
          case 2:
            let item2 = numberItem(nameItem, Number(valueItem));
            safeBoxingConfigItem(_defaultConfig, item2);
            break;
          case 3:
            let item3 = booleanItem(nameItem, Boolean(valueItem));
            safeBoxingConfigItem(_defaultConfig, item3);
            break;
          case 4: {
            let realValue: Record<string, Object>;

            if (typeof valueItem === 'string') {
              realValue = JSON.parse(valueItem) as Record<string, Object>;
            } else {
              realValue = valueItem as Record<string, Object>;
            }

            let item4 = jsonItem(nameItem, realValue);
            safeBoxingConfigItem(_defaultConfig, item4);
            break;
          }
        }


      });


      RemoteConfigManager.sharedInstance().setDefaultConfigs(_defaultConfig);
    } catch (e) {
      console.log(_SolarEngineLog, "setRemoteDefaultConfig: error", e);
    }
  }

  setRemoteConfigEventProperties(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "setRemoteConfigEventProperties", JSON.stringify(properties));
    }
    try {
      const eventProperties = properties as Record<string, string | number | boolean> || {};
      RemoteConfigManager.sharedInstance().setRemoteConfigEventProperties(eventProperties);
    } catch (error) {
      console.error(`${_SolarEngineLog} setRemoteConfigEventProperties failed:`, error);
    }
  }

  setRemoteConfigUserProperties(properties: object): void {
    if (_log) {
      console.log(_SolarEngineLog, "setRemoteConfigUserProperties", JSON.stringify(properties));
    }
    try {
      const userProperties = properties as Record<string, string | number | boolean> || {};

      RemoteConfigManager.sharedInstance().setRemoteConfigUserProperties(userProperties);
    } catch (error) {
      console.error(`${_SolarEngineLog} setRemoteConfigUserProperties failed:`, error);
    }
  }

  fastFetchRemoteConfig(callback: (configs: object) => void): void {
    if (_log) {
      console.log(_SolarEngineLog, "fastFetchRemoteConfig");
    }
    try {
      RemoteConfigManager.sharedInstance().fastAllFetchRemoteConfig((configItemsMap: Map<string, ConfigItem>) => {

        const configArray = Array.from(configItemsMap.values());

        const config: Record<string, string | boolean | number | Object | null> = {};
        const jsonString = JSON.stringify(configArray, null, 2);
        if (_log) {
          console.log(_SolarEngineLog, 'fastAllFetchRemoteConfig:', jsonString);
        }
        for (const item of configArray) {

          let nameItem = item.key;
          let valueItem: string | boolean | number | Object | null = item.value;
          if (_log) {
            console.log(_SolarEngineLog, `Key: ${item.key}, Value: ${item.value}， ${item.type}`);
          }
          if (nameItem !== undefined && nameItem !== null) {
            config[nameItem.toString()] = valueItem;
          } else {
            console.error(_SolarEngineLog, "Invalid or missing key:", item);
          }

        }
        if (_log) {
          console.log(_SolarEngineLog, JSON.stringify(config));
        }
        callback?.(config);
      });


    } catch (e) {
      console.log(_SolarEngineLog, "fastAllFetchRemoteConfig: error", e);
    }
  }

  fastFetchRemoteConfigWithKey(key: string, callback: (value: object) => void): void {
    if (_log) {
      console.log(_SolarEngineLog, "fastFetchRemoteConfigWithKey", key);
    }
    try {


      RemoteConfigManager.sharedInstance().fastFetchRemoteConfig(key, (configItem: ConfigItem | null) => {
        if (configItem == null) {
          if (_log) {
            console.log(_SolarEngineLog, "fastFetchRemoteConfig", key, ": null");
          }
          callback?.([]);
        } else {
          const type = typeof configItem?.value;
          const value = configItem?.value;

          if (_log) {
            console.log(_SolarEngineLog, "fastFetchRemoteConfig", key, " type:", type + " value: " + value);
          }
          if (configItem?.value !== null) {

            callback?.(configItem?.value as object);

          } else {
            callback?.([]);
          }


        }
      })
    } catch (e) {
      callback?.([]);
      console.log(_SolarEngineLog, "fastFetchRemoteConfig: error", e);
    }
  }

  asyncFetchRemoteConfigWithKey(key: string, callback: (value: object) => void) {
    if (_log) {
      console.log(_SolarEngineLog, "asyncFetchRemoteConfig", key);
    }
    try {
      RemoteConfigManager.sharedInstance().asyncFetchRemoteConfig(key, (configItem: ConfigItem | null) => {
        if (configItem == null) {
          if (_log) {
            console.log(_SolarEngineLog, "asyncFetchRemoteConfig", key, ": null");
          }
          callback?.([]);
        } else {
          const type = typeof configItem?.value;
          const value = configItem?.value;

          if (_log) {
            console.log(_SolarEngineLog, "asyncFetchRemoteConfigWithKey", key, " type:", type + " value: " + value);
          }
          if (configItem?.value !== null) {
            //  if (typeof configItem?.value === "object")
            callback?.(configItem?.value as object);
            // else
            //     callback?.(configItem?.value?.toString());

          } else {
            callback?.([]);
          }


        }
      })
    } catch (e) {
      console.log(_SolarEngineLog, "asyncFetchRemoteConfig: error", e);
    }
  }


  asyncFetchRemoteConfig(callback: (value: object) => void): void {
    if (_log) {
      console.log(_SolarEngineLog, "asyncFetchRemoteConfig");
    }
    try {
      RemoteConfigManager.sharedInstance().asyncAllFetchRemoteConfig((configItemsMap: Map<string, ConfigItem>) => {

        const configArray = Array.from(configItemsMap.values());

        const config: Record<string, string | boolean | number | Object | null> = {};
        const jsonString = JSON.stringify(configArray, null, 2);
        if (_log) {
          console.log(_SolarEngineLog, 'asyncFetchRemoteConfig:', jsonString);
        }
        for (const item of configArray) {

          let nameItem = item.key;
          let valueItem: string | boolean | number | Object | null = item.value;
          if (_log) {
            console.log(_SolarEngineLog, `Key: ${item.key}, Value: ${item.value}， ${item.type}`);
          }
          if (nameItem !== undefined && nameItem !== null) {
            config[nameItem.toString()] = valueItem;
          } else {
            console.error(_SolarEngineLog, "Invalid or missing key:", item);
          }

        }
        if (_log) {
          console.log(_SolarEngineLog, JSON.stringify(config));
        }
        callback?.(config);
      });

    } catch (e) {
      console.log(_SolarEngineLog, "asyncFetchRemoteConfig: error", e);
    }
  }

  currentPlatform(): string {
    return 'harmony';
  }
}

export class SolarEngineConfigConstant {
  public static readonly Enable2G = "enable2G";
  public static readonly IsDebugModel = "enableDebug";
  public static readonly LogEnabled = "enableLog";
  public static readonly EnableDelayDeeplink = "enableDeferredDeeplink";
  public static readonly AuthorizationTimeout = "authorizationTimeout"
  public static readonly Harmony = "harmony";
  public static readonly EnableIPV6 = "enableIPV6";
  public static readonly RCEnable = "enable";
  public static readonly RCMergeType = "mergeType";
  public static readonly RCCustomIDProperties = "customIDProperties";
  public static readonly RCCustomIDEventProperties = "customIDEventProperties";
  public static readonly RCCustomIDUserProperties = "customIDUserProperties";
}

export class SEConstant {
  public static readonly First_INNER_TYPE: string = "sdk_inner_type";
  public static readonly First_CustomProperties: string = "customProperties";
  public static readonly First_Register_EVENT: string = "Register";
  public static readonly First_Custom_EVENT: string = "Custom";
  public static readonly First_Custom_EVENT_NAME: string = "eventName";
  public static readonly First_Custom_EVENT_PRE: string = "preProperties";
  public static readonly First_Custom_EVENT_CUSTOM: string = "customProperties";
  public static readonly IAI_AdPlatform: string = "adNetworkPlatform";
  public static readonly IAI_MediationPlatform: string = "mediationPlatform";
  public static readonly IAI_AdAppid: string = "adNetworkAppID";
  public static readonly IAI_AdId: string = "adNetworkPlacementID";
  public static readonly IAI_AdType: string = "adType";
  public static readonly IAI_AdEcpm: string = "ecpm";
  public static readonly IAI_CurrencyType: string = "currency";
  public static readonly IAI_IsRendered: string = "rendered";
  public static readonly IAI_CustomProperties: string = "customProperties";
  public static readonly IAP_PName: string = "productName";
  public static readonly IAP_PID: string = "productID";
  public static readonly IAP_PCount: string = "productCount";
  public static readonly IAP_Currency: string = "currency";
  public static readonly IAP_OrderId: string = "orderId";
  public static readonly IAP_FailReason: string = "failReason";
  public static readonly IAP_PayType: string = "payType";
  public static readonly IAP_Amount: string = "payAmount";
  public static readonly IAP_Paystatus: string = "payStatus";
  public static readonly IAP_CustomProperties: string = "customProperties";
  public static readonly AdClick_AdPlatform: string = "adNetworkPlatform";
  public static readonly AdClick_MediationPlatform: string = "mediationPlatform";
  public static readonly AdClick_AdId: string = "adNetworkPlacementID";
  public static readonly AdClick_AdType: string = "adType";
  public static readonly AdClick_CustomProperties: string = "customProperties";
  public static readonly Register_Type: string = "registerType";
  public static readonly Register_Status: string = "registerStatus";
  public static readonly Register_CustomProperties: string = "customProperties";
  public static readonly Login_Type: string = "loginType";
  public static readonly Login_Status: string = "loginStatus";
  public static readonly Login_CustomProperties: string = "customProperties";
  public static readonly Order_ID: string = "orderID";
  public static readonly Order_Pay_Amount: string = "payAmount";
  public static readonly Order_Currency_Type: string = "currency";
  public static readonly Order_Pay_Type: string = "payType";
  public static readonly Order_Status: string = "status";
  public static readonly Order_CustomProperties: string = "customProperties";
  public static readonly AppAttr_Ad_Network: string = "adNetwork";
  public static readonly AppAttr_Sub_Channel: string = "subChannel";
  public static readonly AppAttr_Ad_Account_ID: string = "adAccountID";
  public static readonly AppAttr_Ad_Account_Name: string = "adAccountName";
  public static readonly AppAttr_Ad_Campaign_ID: string = "adCampaignID";
  public static readonly AppAttr_Ad_Campaign_Name: string = "adCampaignName";
  public static readonly AppAttr_Ad_Offer_ID: string = "adOfferID";
  public static readonly AppAttr_Ad_Offer_Name: string = "adOfferName";
  public static readonly AppAttr_Ad_Creative_ID: string = "adCreativeID";
  public static readonly AppAttr_Ad_Creative_Name: string = "adCreativeName";
  public static readonly AppAttr_AttributionPlatform: string = "attributionPlatform";
  public static readonly AppAttr_Ad_CustomProperties: string = "customProperties";
}

export class SERCConstant {
  public static readonly NAME: string = "name";
  public static readonly VALUE: string = "value";
  public static readonly TYPE: string = "type";
}
