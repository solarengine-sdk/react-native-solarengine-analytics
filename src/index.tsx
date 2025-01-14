import { NativeModules, Platform } from 'react-native';
import { log } from './Utils';
import { ConfigItem,stringItem,booleanItem,numberItem,objectItem } from './ConfigItem';

import type { SolarEngineInitiateOptions,
  InitiateCompletionInfo,
  se_initial_config,
  RemoteConfig,
  attribution,
  deeplink,
  delayDeeplink,
  requestTrackingAuthorizationCompletion,
  DeepLinkInfo,
  DelayDeepLinkInfo,
  CustomDomain
  } from './se_initial_config';

import { RemoteConfigMergeType,
  ATTrackingManagerAuthorizationStatus,
    } from './se_initial_config'

import type {
  SEAdImpressionEventAttribute,
  SEAdClickEventAttribute,
  SEIAPEventAttribute,
  SEAppAttrEventAttribute,
  SEOrderEventAttribute,
  SERegisterEventAttribute,
  SELoginEventAttribute,
  SECustomEventAttribute
} from './pre_defined_event'
import { PresetEventType,
   AdType,
   SEIAPStatus,
   decorateEventType,
   SKAdNetworkCoarseType,
   Alipay,
   Weixin,
   ApplePay,
   Paypal,
  } from './pre_defined_event'

const SolarEnginePluginVersion = '1.5.0';

const LINKING_ERROR =
  `The package 'react-native-solarengine-analysis' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

  

const SolarengineAnalysis = NativeModules.SolarengineAnalysisReactNative
  ? NativeModules.SolarengineAnalysisReactNative
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );


  /************** SDK Initiate *****************/

export function preInit(appKey: string)
{
  SolarengineAnalysis.preInit(appKey);
}

function _setReactNativeBridgeVersion(){

    SolarengineAnalysis.setReactNativeBridgeVersion(SolarEnginePluginVersion);
}

function _handleAttribution(attribution:attribution|undefined){

  if (attribution === undefined){
    return;
  }

  SolarengineAnalysis.registerAttribution((attributionResult:Object) => {

    const dictData = attributionResult as { [key: string]: string | number | any[] |{ [key: string]: string | number | any[] }};

    var reactnative_code = null;
    var reactnative_data = null;

    if (Platform.OS === 'ios') {
      reactnative_code = dictData["reactnative_code"]
      reactnative_data = dictData["reactnative_data"];      
    } else if (Platform.OS === 'android') {
        var android_object_wrapper = dictData["android_object_wrapper_key"] as { [key: string]: string | number | any[] };
        reactnative_code = android_object_wrapper["reactnative_code"];
        reactnative_data = android_object_wrapper["reactnative_data"];
    }

    let code = reactnative_code as number;
    if(code === 0){
      if(attribution){
        let data = reactnative_data as Object;
        attribution(code,data);
      }
    }else{
      if(attribution){
        attribution(code);
      }
    }
   
  });

}

function _handleDeepLink(deeplink:deeplink|undefined){

  if (deeplink === undefined){
    return;
  }

  SolarengineAnalysis.registerDeeplink((deeplinkResult:Object) => {

    const dictData = deeplinkResult as { [key: string]: string | number | Object };

    var reactnative_code = null;
    var reactnative_data = null;

    if (Platform.OS === 'ios') {
      reactnative_code = dictData["reactnative_code"]
      reactnative_data = dictData["reactnative_data"];      
    } else if (Platform.OS === 'android') {
        var android_object_wrapper = dictData["android_object_wrapper_key"] as { [key: string]: string | number | any[] };
        reactnative_code = android_object_wrapper["reactnative_code"];
        reactnative_data = android_object_wrapper["reactnative_data"];
    }

    if(reactnative_code){
      let code = reactnative_code as number;
      if(code === 0){
        let data = reactnative_data as DeepLinkInfo;
        // as { [key: string]: string | any[] };
        if(deeplink){
          if(data != undefined){

            deeplink(code,data);
          }else{
            deeplink(-2);
          }
        }

      }else{
        if(deeplink){
          deeplink(code);
        }
      }
    }else{
      if(deeplink){
        deeplink(-1);
      }
    }    
  });
}
function _handleDelayDeeplink(delayDeeplink:delayDeeplink|undefined){

  if (delayDeeplink === undefined){
    return;
  }

  SolarengineAnalysis.registerDelayDeeplink((delayDeeplinkResult:Object) => {

    const dictData = delayDeeplinkResult as { [key: string]: string | number | Object };

    var reactnative_code = null;
    var reactnative_data = null;

    if (Platform.OS === 'ios') {
      reactnative_code = dictData["reactnative_code"]
      reactnative_data = dictData["reactnative_data"];      
    } else if (Platform.OS === 'android') {
        var android_object_wrapper = dictData["android_object_wrapper_key"] as { [key: string]: string | number | any[] };
        reactnative_code = android_object_wrapper["reactnative_code"];
        reactnative_data = android_object_wrapper["reactnative_data"];
    }
    if(reactnative_code){
      let code = reactnative_code as number;
      if(code === 0){
        let data = reactnative_data as DelayDeepLinkInfo;
        // as { [key: string]: string | any[] };
        if(delayDeeplink){
          if(data != undefined){

            delayDeeplink(code,data);
          }else{
            delayDeeplink(-2);
          }
        }

      }else{
        if(delayDeeplink){
          delayDeeplink(code);
        }
      }
    }else{
      if(delayDeeplink){
        delayDeeplink(-1);
      }
    }
  });  
}

function _buildInitiateCompletionInfo(code: number):InitiateCompletionInfo{
  let result:InitiateCompletionInfo = {
    success: false,
    errorCode: undefined,
    message : undefined
  }
    if (code === 0) {
      result.success = true;
      result.message = "SDK Initiate Successfully";
    }else{
      result.success = false;
      result.errorCode = code;
      switch (code) {
        case 101:
          result.message = `"initiate()" should be invoked after "preInit()"`;
          break;
        case 102:
          result.message = "Your appKey is invalid";
          break;
      }

    }
    return result;
}

export function initialize(appKey:string,options:SolarEngineInitiateOptions,completion: (result: InitiateCompletionInfo) => void) {

  _setReactNativeBridgeVersion();

  _handleAttribution(options.attribution);
  _handleDeepLink(options.deeplink);
  _handleDelayDeeplink(options.delayDeeplink);

    SolarengineAnalysis.registerInitiateComplete((code:number) => {

      let completionInfo:InitiateCompletionInfo = _buildInitiateCompletionInfo(code);
      completion(completionInfo);
    });
  
    SolarengineAnalysis.initialize(
      appKey,
      options.config,
      options.remoteConfig,
      options.customDomain
    );   
}

  /************** Attribution *****************/
export function retrieveAttribution(): Object|null {
  if (Platform.OS === 'ios') {
    return SolarengineAnalysis.retrieveAttribution();

  } else if (Platform.OS === 'android') {
    let result = SolarengineAnalysis.retrieveAttribution();
    if (result == null) {
      return null;
    }

    const dictData = result as { [key: string]: Object };
    let resultObject = dictData["android_object_wrapper_key"] as Object;
    return resultObject;

  }
    return SolarengineAnalysis.retrieveAttribution();
}

  /************** DistinctId *****************/
export function fetchDistinctId():string{
  let distinctId = SolarengineAnalysis.fetchDistinctId();
  return distinctId;
}

  /************** VisitorID *****************/
export function setVisitorID(visitorID:string){
  SolarengineAnalysis.setVisitorID(visitorID);
}

export function fetchVisitor():string{
  let visitor = SolarengineAnalysis.fetchVisitor();
  return visitor;
}

  /************** AccountID *****************/
export function login(accountID:string) {
  SolarengineAnalysis.login(accountID);
}
export function fetchAccount():string {
  let accountID = SolarengineAnalysis.fetchAccount();
  return accountID;
}
export function logout() {
  SolarengineAnalysis.logout();
}

  /************** SuperProperties *****************/
export function setSuperProperties(superProperties:Object){
  SolarengineAnalysis.setSuperProperties(superProperties);
}
export function unsetSuperProperty(key:string){
  SolarengineAnalysis.unsetSuperProperty(key);
}
export function clearSuperProperties(){
  SolarengineAnalysis.clearSuperProperties();
}

  /************** Properties for all Preset event *****************/
export function retrievePresetProperties():Object{
  if (Platform.OS === 'ios') {
    let presetProperties = SolarengineAnalysis.retrievePresetProperties();
    return presetProperties;

  } else if (Platform.OS === 'android') {
    let result = SolarengineAnalysis.retrievePresetProperties();
    if (result == null) return {};

    const dictData = result as { [key: string]: Object };
    let resultObject = dictData["android_object_wrapper_key"] as Object;
    return resultObject;
  }

  let presetProperties = SolarengineAnalysis.retrievePresetProperties();
  return presetProperties;
}

  /************** Properties for specified Preset event *****************/
export function setPreSetEventWithProperties(eventType:PresetEventType, properties:Object){

  SolarengineAnalysis.setPresetProperties(eventType, properties);
}

  /************** Predefined Events *****************/
export function trackAdImpressionWithAttributes(adImpressionEventAttribute:SEAdImpressionEventAttribute){
  SolarengineAnalysis.trackAdImpressionWithAttributes(adImpressionEventAttribute);  
}
export function trackAdClickWithAttributes(adClickEventAttribute:SEAdClickEventAttribute){
  SolarengineAnalysis.trackAdClickWithAttributes(adClickEventAttribute);
}
export function trackIAPWithAttributes(iapEventAttribute:SEIAPEventAttribute){
  SolarengineAnalysis.trackIAPWithAttributes(iapEventAttribute);
}
export function trackAppAttrWithAttributes(appAttrEventAttribute:SEAppAttrEventAttribute){
  SolarengineAnalysis.trackAppAttrWithAttributes(appAttrEventAttribute);
}
export function trackOrderWithAttributes(orderEventAttribute:SEOrderEventAttribute){
  SolarengineAnalysis.trackOrderWithAttributes(orderEventAttribute);
}
export function trackRegisterWithAttributes(registerEventAttribute:SERegisterEventAttribute){
  SolarengineAnalysis.trackRegisterWithAttributes(registerEventAttribute);
}
export function trackLoginWithAttributes(loginEventAttribute:SELoginEventAttribute){
  SolarengineAnalysis.trackLoginWithAttributes(loginEventAttribute);
}

  /************** Custom Event *****************/
export function trackCustomEvent(eventName:string,
                          customProperties?:Object,
                             preProperties?:Object){
 SolarengineAnalysis.trackCustomEvent(eventName, customProperties, preProperties);                              
}

  /************** Duration Event *****************/
export function eventStart(eventName:string){
  SolarengineAnalysis.eventStart(eventName);
}
export function eventEnd(eventName:string,properties:Object){
  SolarengineAnalysis.eventEnd(eventName,properties);
}
  /************** First-Time Event *****************/
export function trackFirstEvent(firstCheckId:string,eventAttribute:
                                                  SEIAPEventAttribute|
                                                  SEAppAttrEventAttribute|
                                                  SEOrderEventAttribute|
                                                  SERegisterEventAttribute|
                                                  SELoginEventAttribute|
                                                  SEAdImpressionEventAttribute|
                                                  SEAdClickEventAttribute|
                                                  SECustomEventAttribute){
  let _eventAttribute = decorateEventType(eventAttribute);                                                  
  SolarengineAnalysis.trackFirstEvent(firstCheckId,_eventAttribute);
}
  /************** Set User Property *****************/
export function userPropertiesInit(properties:Object){
  SolarengineAnalysis.userPropertiesInit(properties);
}
export function userPropertiesUpdate(properties:Object){
  SolarengineAnalysis.userPropertiesUpdate(properties);
}
export function userPropertiesAdd(properties:Map<string,number>){
  const obj: Record<string, number> = {};
  for (const [key, value] of properties) {
      obj[key] = value;
  }
  SolarengineAnalysis.userPropertiesAdd(obj);
}
export function userPropertiesUnset(keys:Array<string>){
  SolarengineAnalysis.userPropertiesUnset(keys);
}
export function userPropertiesAppend(properties:Object){
  SolarengineAnalysis.userPropertiesAppend(properties);
}

export enum SEUserDeleteType {
  ByAccountId = 1,
  ByVisitorId = 2,
}
export function userPropertiesDelete(deleteType:SEUserDeleteType){
  SolarengineAnalysis.userPropertiesDelete(deleteType);
}

  /************** Report Event Immediately *****************/
export function reportEventimmediately(){
  SolarengineAnalysis.reportEventimmediately();
}


  /************** Deep Linking *****************/
export function trackAppReEngagement(customProperties:Object){
  SolarengineAnalysis.trackAppReEngagement(customProperties);
}
export function appDeeplinkOpenURL(urlString:string){
  SolarengineAnalysis.appDeeplinkOpenURL(urlString);
}  
  /************** Deferred Deep Linking *****************/
  /************** Connect Native App & H5 *****************/

  /************** RemoteConfig *****************/
export function setDefaultConfig(configs:Array<ConfigItem>){

  let _configs = new Array<Object>();
  for(let _config  of configs){
    let config = _config as ConfigItem;
    let name = config.name;
    let value = config.value;
    let type:number = config.type;

    let obj = {name, "value":value,"type":type}
    _configs.push(obj)
  }
  if(_configs.length == 0){
    log("The default config that you passed is empty");
    return;
  }

  SolarengineAnalysis.setDefaultConfig(_configs);

}
export function setRemoteConfigEventProperties(properties:Object){
  SolarengineAnalysis.setRemoteConfigEventProperties(properties);
}
export function setRemoteConfigUserProperties(properties:Object){
  SolarengineAnalysis.setRemoteConfigUserProperties(properties);
}

export function fastFetchRemoteConfigWithKey(key:string,completion: (value:object|null) => void){
   SolarengineAnalysis.fastFetchRemoteConfigWithKey(key,(value?:object) => {
    if (value){
      completion(value);
    }else{
      completion(null);
    }      
});
}
export function fastFetchRemoteConfig(completion: (configs:Object|null) => void){

  SolarengineAnalysis.fastFetchRemoteConfig((configs?:Object) => {

    if(completion){
      if (configs){
        completion(configs);
      }else{
        completion(null);
      }
    }
  });
}
export function asyncFetchRemoteConfigWithKey(key:string,completion: (value:object|null) => void){
  SolarengineAnalysis.asyncFetchRemoteConfigWithKey(key,(value?:object) => {
      if (value){
        completion(value);
      }else{
        completion(null);
      }      
  });
}
export function asyncFetchRemoteConfig(completion: (configs:Object|null) => void){
  SolarengineAnalysis.asyncFetchRemoteConfig((configs?:Object) => {
    if(completion){

      if (configs){
        completion(configs);
      }else{
        completion(null);
      }
    }
  });
}
  /************** GDPR *****************/
  export function setGDPRArea(isGDPRArea:boolean){
    SolarengineAnalysis.setGDPRArea(isGDPRArea);
  }

  /************** iOS *****************/
  /************** ATT Authorization *****************/

export function requestTrackingAuthorization(completion?:requestTrackingAuthorizationCompletion) {

  if (Platform.OS === 'ios') {
    SolarengineAnalysis.requestTrackingAuthorization((status: ATTrackingManagerAuthorizationStatus) => {

      if(completion){
        completion(status);
      }      
    });     
  } else if (Platform.OS === 'android') {
    log(`"requestTrackingAuthorization" not supported in Android OS device`);
  }

}

  /************** SKAdNetwork *****************/
export function updatePostbackConversionValue(conversionValue:number,
  coarseValue?:SKAdNetworkCoarseType,
  lockWindow?:Boolean):  Promise<Object|null> {
    
    if (Platform.OS === 'ios') {
      
      return new Promise((resolve) => {

        let  completionHandler = (error:Object) => {
          if(error){            
            resolve(error);
          }else{
            resolve(null)
          }
        }
        let _type:number = 0;
        let _conversionValue:number = conversionValue;  
        if (_conversionValue){
          _type = 1;
        }      
        let _coarseValue:string = "";
        if(coarseValue != null){
          _type = _type|2;
          _coarseValue = coarseValue;
        }
        let _lockWindow:Boolean = false;
        if(lockWindow != null){
          _type = _type|4;
          _lockWindow = lockWindow;
        }

        SolarengineAnalysis.updatePostbackConversionValue(_type,
                                            _conversionValue,
                                            _coarseValue,
                                            _lockWindow,
                                            completionHandler);     
      });
         
    } else if (Platform.OS === 'android') {
      log(`"updatePostbackConversionValue" not supported in Android OS device`);
      return Promise.resolve(null);
    }
    return Promise.reject(new Error('Unsupported platform'));
  }


  /************** Android *****************/
export function setOaid(oaid:string){
  if (Platform.OS === 'ios') {
    log(`"setOaid" not supported in iOS device`);
  } else if (Platform.OS === 'android') {
    SolarengineAnalysis.setOaid(oaid);
  }
}
export function setGaid(gaid:string){
  if (Platform.OS === 'ios') {
    log(`"setGaid" not supported in iOS device`);
  } else if (Platform.OS === 'android') {
    SolarengineAnalysis.setGaid(gaid);
  }
}
export function setChannel(channel:string){
  if (Platform.OS === 'ios') {
    log(`"setChannel" not supported in iOS device`);
  } else if (Platform.OS === 'android') {
    SolarengineAnalysis.setChannel(channel);
  }
}

export  type { 
  se_initial_config,
  RemoteConfig,
  deeplink,
  delayDeeplink,
  attribution,
  requestTrackingAuthorizationCompletion,
  SolarEngineInitiateOptions,
  InitiateCompletionInfo,
  DeepLinkInfo,
  DelayDeepLinkInfo,
  CustomDomain,
  SEAdImpressionEventAttribute,
  SEAdClickEventAttribute,
  SEIAPEventAttribute,
  SEAppAttrEventAttribute,
  SEOrderEventAttribute,
  SERegisterEventAttribute,
  SELoginEventAttribute,
  SECustomEventAttribute
 };

export   {  RemoteConfigMergeType,  
    ATTrackingManagerAuthorizationStatus,
    PresetEventType,
    AdType,
    SEIAPStatus,
    SKAdNetworkCoarseType,
    Alipay,
    Weixin,
    ApplePay,
    Paypal,
    ConfigItem,

  }
export default{

  //Function
  preInit,
  initialize,
  retrieveAttribution,
  fetchDistinctId,
  setVisitorID,
  fetchVisitor,
  login,
  fetchAccount,
  logout,
  setSuperProperties,
  unsetSuperProperty,
  clearSuperProperties,
  retrievePresetProperties,
  setPreSetEventWithProperties,
  trackAdImpressionWithAttributes,
  trackAdClickWithAttributes,
  trackIAPWithAttributes,
  trackAppAttrWithAttributes,
  trackOrderWithAttributes,
  trackRegisterWithAttributes,
  trackLoginWithAttributes,
  trackCustomEvent,
  eventStart,
  eventEnd,
  trackFirstEvent,
  userPropertiesInit,
  userPropertiesUpdate,
  userPropertiesAdd,
  userPropertiesUnset,
  userPropertiesAppend,
  userPropertiesDelete,
  reportEventimmediately,
  trackAppReEngagement,
  appDeeplinkOpenURL,
  requestTrackingAuthorization,
  updatePostbackConversionValue,
  setGDPRArea,
  setOaid,
  setGaid,
  setChannel,

  //Remote Configuration
  setDefaultConfig,
  setRemoteConfigEventProperties,
  setRemoteConfigUserProperties,
  fastFetchRemoteConfigWithKey,
  fastFetchRemoteConfig,
  asyncFetchRemoteConfigWithKey,
  asyncFetchRemoteConfig,

  stringItem,
  booleanItem,
  numberItem,
  objectItem,

  ConfigItem,


}
