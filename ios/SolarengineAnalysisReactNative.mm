#import "SolarengineAnalysisReactNative.h"

#import <React/RCTConvert.h>
#import <SolarEngineSDK/SolarEngineSDK.h>
#if __has_include(<SolarEngineSDK/SESDKForCN.h>)
#import <SolarEngineSDK/SESDKForCN.h>
#else
#endif


#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
#import <SESDKRemoteConfig/SESDKRemoteConfig.h>
#else
#endif

#import "SEWrapperManager.h"
#import "SolarengineEventAttribute.h"

#if __has_include(<StoreKit/SKAdNetwork.h>)
#import <StoreKit/SKAdNetwork.h>
#else
#endif


@implementation SolarengineAnalysisReactNative
RCT_EXPORT_MODULE()

static BOOL solarengine_log_controll = NO;


+(void)log:(id)obj method:(SEL)sel{
//  if (solarengine_log_controll == NO) {
//    return;
//  }
  NSLog(@"[SolarEngine iOS Bridge] method:%@\n  log:%@\n",NSStringFromSelector(sel), obj);
}
+(void)logErrorMsg:(id)obj method:(SEL)sel{

  NSLog(@"[SolarEngine iOS Bridge] method:%@\n  log:%@\n",NSStringFromSelector(sel), obj);
}

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(a * b);

    resolve(result);
}


RCT_EXPORT_METHOD(setReactNativeBridgeVersion:(NSString *)version)
{
  NSString *log = [NSString stringWithFormat:@"version: %@",version];
  [SolarengineAnalysisReactNative log:log method:_cmd];

  SEWrapperManager *wrapper = [SEWrapperManager sharedInstance];
  wrapper.sub_lib_version = [NSString stringWithFormat:@"%@",version];
  wrapper.sdk_type = @"reactnative";
}

RCT_EXPORT_METHOD(preInit:(NSString *)appKey)
{
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  if (appKey == nil) {
      NSString *message = @"appKey can`t be nil";
    [SolarengineAnalysisReactNative logErrorMsg:message method:_cmd];
      NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
      @throw myException;
    }
    [[SolarEngineSDK sharedInstance] preInitWithAppKey:appKey];
}

RCT_EXPORT_METHOD(registerAttribution:(RCTResponseSenderBlock)attribution ){
    [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

    if(attribution == nil){
        return;
    }

    [[SolarEngineSDK sharedInstance] setAttributionCallback:^(int code, NSDictionary * _Nullable attributionData) {

        NSString *log = [NSString stringWithFormat:@"attribution code: %d",code];
        [SolarengineAnalysisReactNative log:log method:_cmd];

        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        if (attributionData) {
            [result setObject:attributionData forKey:@"reactnative_data"];
        }
        [result setObject:@(code) forKey:@"reactnative_code"];
        if(attribution){
            attribution(@[result]);
        }
    }];
}
RCT_EXPORT_METHOD(registerDeeplink:(RCTResponseSenderBlock)deeplink ){
    [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

    if(deeplink == nil){
        return;
    }

    [[SolarEngineSDK sharedInstance] setDeepLinkCallback:^(int code, SEDeeplinkInfo * _Nullable deeplinkInfo) {
    
        NSString *log = [NSString stringWithFormat:@"deeplink code: %d",code];
        [SolarengineAnalysisReactNative log:log method:_cmd];

        if (code == 0) {

            NSString *log = [NSString stringWithFormat:@"sedpLink: %@",deeplinkInfo.sedpLink];
            [SolarengineAnalysisReactNative log:log method:_cmd];

            NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
            if (deeplinkInfo) {
            if(deeplinkInfo.sedpLink){
                [data setObject:deeplinkInfo.sedpLink forKey:@"sedpLink"];
            }
            if(deeplinkInfo.turlId){
                [data setObject:deeplinkInfo.turlId forKey:@"turlId"];
            }
            if(deeplinkInfo.from){
                [data setObject:deeplinkInfo.from forKey:@"from"];
            }
            if(deeplinkInfo.customParams){
                [data setObject:deeplinkInfo.customParams forKey:@"customParams"];
            }
            }
            [result setObject:@(code) forKey:@"reactnative_code"];
            [result setObject:data forKey:@"reactnative_data"];

            if(deeplink){
                deeplink(@[result]);
            }                
        } else {
          NSString *log = [NSString stringWithFormat:@"deeplink error code: %d",code];
          [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

            NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
            [result setObject:@(code) forKey:@"reactnative_code"];
            if(deeplink){
                deeplink(@[result]);
            }                
        }
    }];
}
RCT_EXPORT_METHOD(registerDelayDeeplink:(RCTResponseSenderBlock)delayDeeplink ){
    [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

    if(delayDeeplink == nil){
        return;
    }
    [[SolarEngineSDK sharedInstance] setDelayDeeplinkDeepLinkCallbackWithSuccess:^(SEDelayDeeplinkInfo * _Nullable deeplinkInfo) {

        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];

        int _code = 0;//success
        if (deeplinkInfo) {
        _code = 0;
        if(deeplinkInfo.sedpLink){
            [data setObject:deeplinkInfo.sedpLink forKey:@"sedpLink"];
        }else{
            [data setObject:@"" forKey:@"sedpLink"];
        }
        if(deeplinkInfo.turlId){
            [data setObject:deeplinkInfo.turlId forKey:@"turlId"];
        }else{
            [data setObject:@"" forKey:@"turlId"];
        }
        if(deeplinkInfo.sedpUrlscheme){
            [data setObject:deeplinkInfo.sedpUrlscheme forKey:@"sedpUrlscheme"];
        }else{
            [data setObject:@"" forKey:@"sedpUrlscheme"];
        }
        [result setObject:data forKey:@"reactnative_data"];
        }else{
        _code = -2;
        }
        [result setObject:@(_code) forKey:@"reactnative_code"];
        if(delayDeeplink){
            delayDeeplink(@[result]);
        }
    } fail:^(NSError * _Nullable error) {

        [SolarengineAnalysisReactNative logErrorMsg:error method:_cmd];

        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        [result setObject:@(error.code) forKey:@"reactnative_code"];
        if(delayDeeplink){
            delayDeeplink(@[result]);
        }
    }];
}
RCT_EXPORT_METHOD(registerInitiateComplete:(RCTResponseSenderBlock)initiateComplete){
    if(initiateComplete == nil){
        return;
    }

    [[SolarEngineSDK sharedInstance] setInitCompletedCallback:^(int code) {
        [SolarengineAnalysisReactNative log:[NSString stringWithFormat:@"SDK init result code = %d",code] method:_cmd];
        if(initiateComplete) {
            int result = code;
            initiateComplete(@[@(result)]);
        }
    }];
}

RCT_EXPORT_METHOD(initialize:(NSString *)appKey
                config:(NSDictionary *)config
                remoteConfig:(NSDictionary *)remoteConfig
                customDomain:(NSDictionary *)customDomain
                )
{
    [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

    if (appKey == nil) {
      NSString *message = @"appKey can`t be nil";    
      [SolarengineAnalysisReactNative logErrorMsg:message method:_cmd];
      NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
      @throw myException;
    }

    SEConfig *seconfig = [[SEConfig alloc] init];

    NSDictionary *iosConfigs = config[@"ios"];
#if __has_include(<SolarEngineSDK/SESDKForCN.h>)

    if (iosConfigs[@"caid"]) {
        seconfig.caid = iosConfigs[@"caid"];
    }
#else
  ;
#endif
  
/*
ts model keys:
  enable: boolean;
  receiverDomain: string;
  ruleDomain?:string;
  receiverTcpHost?:string;
  ruleTcpHost?:string;
  gatewayTcpHost?:string;
*/  
  if (customDomain && customDomain[@"enabled"]){
      SECustomDomain *model = [[SECustomDomain alloc] init];
      BOOL enabled = [customDomain[@"enabled"] boolValue];
      model.enable = enabled; // 开启私有化部署
      if ([customDomain objectForKey:@"receiverDomain"]) {
        model.receiverDomain = customDomain[@"receiverDomain"]; // 您的https 域名
      }
      if ([customDomain objectForKey:@"ruleDomain"]) {
        model.ruleDomain = customDomain[@"ruleDomain"]; // 您的https 域名
      }
      if ([customDomain objectForKey:@"receiverTcpHost"]) {
        model.receiverTcpHost = customDomain[@"receiverTcpHost"]; // 您的https 域名
      }
      if ([customDomain objectForKey:@"ruleTcpHost"]) {
        model.ruleTcpHost = customDomain[@"ruleTcpHost"]; // 您的https 域名
      }
      if ([customDomain objectForKey:@"gatewayTcpHost"]) {
        model.gatewayTcpHost = customDomain[@"gatewayTcpHost"]; // 您的https 域名
      }
      seconfig.customDomain = model;
  }

#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)

  if (remoteConfig[@"enabled"]) {
    BOOL enabled = [remoteConfig[@"enabled"] boolValue];
    
    SERemoteConfig *remote = [[SERemoteConfig alloc] init];
    remote.enable = enabled;
    if (remoteConfig[@"mergeType"]) {
      int mergeType = [remoteConfig[@"mergeType"] intValue];
      if (mergeType == 1) {
        remote.mergeType = SERCMergeTypeUser;
      }else if (mergeType == 2){
        remote.mergeType = SERCMergeTypeDefault;
      }else{
        [SolarengineAnalysisReactNative logErrorMsg:@"mergeType is invalid" method:_cmd];
      }
    }
    id customIDProperties = remoteConfig[@"customIDProperties"];
    if ([customIDProperties isKindOfClass:NSDictionary.class]) {
      remote.customIDProperties = customIDProperties;
    }else{
      [SolarengineAnalysisReactNative logErrorMsg:@"customIDProperties is invalid" method:_cmd];
    }
    
    id customIDEventProperties = remoteConfig[@"customIDEventProperties"];
    if ([customIDEventProperties isKindOfClass:NSDictionary.class]) {
      remote.customIDEventProperties = customIDEventProperties;
    }else{
      [SolarengineAnalysisReactNative logErrorMsg:@"customIDEventProperties is invalid" method:_cmd];
    }
    
    id customIDUserProperties = remoteConfig[@"customIDUserProperties"];
    if ([customIDUserProperties isKindOfClass:NSDictionary.class]) {
      remote.customIDUserProperties = customIDUserProperties;
    }else{
      [SolarengineAnalysisReactNative logErrorMsg:@"customIDUserProperties is invalid" method:_cmd];
    }

    BOOL enableLog = NO;
    if (config[@"enableLog"]) {
      enableLog = [config[@"enableLog"] boolValue];
      remote.logEnabled = enableLog;
    }

    seconfig.remoteConfig = remote;
  }else{
    [SolarengineAnalysisReactNative logErrorMsg:@"enabled is missing" method:_cmd];
  }
#else
  ;
#endif
  
    if (iosConfigs[@"attAuthorizationWaitingInterval"]){
        NSNumber *attAuthorizationWaitingInterval = iosConfigs[@"attAuthorizationWaitingInterval"];
        int interval = [attAuthorizationWaitingInterval intValue];
      seconfig.attAuthorizationWaitingInterval = interval; // SDK最多等待用户ATT授权，最多等待120秒
    }

    BOOL enableLog = NO;
    if (config[@"enableLog"]) {
      enableLog = [config[@"enableLog"] boolValue];
      seconfig.logEnabled = enableLog;
      solarengine_log_controll = enableLog;
    }
    BOOL enable2G = NO;
    if (config[@"enable2G"]) {
        enable2G = [config[@"enable2G"] boolValue];
      seconfig.enable2GReporting = enable2G;
    }
    BOOL enableDebug = NO;
    if (config[@"enableDebug"]) {
        enableDebug = [config[@"enableDebug"] boolValue];
      seconfig.isDebugModel = enableDebug;
    }
#if __has_include(<SolarEngineSDK/SESDKForCN.h>)
  ;
#else
  BOOL enableCoppa = NO;
  if (config[@"enableCoppa"]) {
      enableCoppa = [config[@"enableCoppa"] boolValue];
      seconfig.setCoppaEnabled = enableCoppa;
  }
  BOOL enableGDPR = NO;
  if (config[@"enableGDPR"]) {
      enableGDPR = [config[@"enableGDPR"] boolValue];
      seconfig.isGDPRArea = enableGDPR;
  }
  BOOL enableKidsApp = NO;
  if (config[@"enableKidsApp"]) {
      enableKidsApp = [config[@"enableKidsApp"] boolValue];
      seconfig.setKidsAppEnabled = enableKidsApp;
  }
#endif

    BOOL enableDelayDeeplink = NO;
    if (config[@"enableDelayDeeplink"]) {
        enableDelayDeeplink = [config[@"enableDelayDeeplink"] boolValue];
      seconfig.enableDelayDeeplink = enableDelayDeeplink;
    }

    [SolarengineAnalysisReactNative log:config method:_cmd];
    [[SolarEngineSDK sharedInstance] startWithAppKey:appKey config:seconfig];
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(retrieveAttribution){
    NSDictionary *retrieveAttribution = [[SolarEngineSDK sharedInstance] getAttributionData];
    return retrieveAttribution;
}
RCT_EXPORT_METHOD(setGDPRArea:(BOOL)isGDPR){
  [[SolarEngineSDK sharedInstance] setGDPRArea:isGDPR];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchDistinctId){
    NSString *distinctId =  [[SolarEngineSDK sharedInstance] getDistinctId];
    return distinctId;
}
RCT_EXPORT_METHOD(setVisitorID:(NSString *)visitorID){
    [[SolarEngineSDK sharedInstance] setVisitorID:visitorID];
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchVisitor){
    NSString *visitorId = [[SolarEngineSDK sharedInstance] visitorID];
    return visitorId;
}
RCT_EXPORT_METHOD(login:(NSString *)accountID){
    [[SolarEngineSDK sharedInstance] loginWithAccountID:accountID];
}
RCT_EXPORT_METHOD(logout){
    [[SolarEngineSDK sharedInstance] logout];
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchAccount){
    NSString *accountID = [[SolarEngineSDK sharedInstance] accountID];
    return accountID;
}
RCT_EXPORT_METHOD(setSuperProperties:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] setSuperProperties:properties];
}
RCT_EXPORT_METHOD(clearSuperProperties){
    [[SolarEngineSDK sharedInstance] clearSuperProperties];
}
RCT_EXPORT_METHOD(unsetSuperProperty:(NSString *)key){
    [[SolarEngineSDK sharedInstance] unsetSuperProperty:key];
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(retrievePresetProperties){
    NSDictionary *properties = [[SolarEngineSDK sharedInstance] getPresetProperties];
    return properties;
}
RCT_EXPORT_METHOD(setPresetProperties:(int)eventType
                    properties:(NSDictionary *)properties){
  BOOL AppInstall = NO;//1
  BOOL AppStart = NO;//2
  BOOL AppEnd = NO;//4
    // int eventType = [_eventType intValue];
    if ((eventType & 1) == 1) AppInstall = YES;
    if ((eventType & 2) == 2) AppStart = YES;
    if ((eventType & 4) == 4) AppEnd = YES;

    if (AppInstall && AppStart && AppEnd){
     
      [[SolarEngineSDK sharedInstance] setPresetEvent:SEPresetEventTypeAppAll 
        withProperties:properties];    
        return;     
    }

    if (AppInstall){
        [[SolarEngineSDK sharedInstance] setPresetEvent:SEPresetEventTypeAppInstall 
        withProperties:properties];        
    }
    if (AppStart){
        [[SolarEngineSDK sharedInstance] setPresetEvent:SEPresetEventTypeAppStart 
        withProperties:properties];        
    }
    if (AppEnd){
        [[SolarEngineSDK sharedInstance] setPresetEvent:SEPresetEventTypeAppEnd 
        withProperties:properties];        
    }
}
RCT_EXPORT_METHOD(trackAdImpressionWithAttributes:(NSDictionary *)eventAttribute){

    SEAdImpressionEventAttribute *attribute = [SolarengineEventAttribute adImpressionEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackAdImpressionWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackAdClickWithAttributes:(NSDictionary *)eventAttribute){
    SEAdClickEventAttribute *attribute = [SolarengineEventAttribute adClickEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackAdClickWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackIAPWithAttributes:(NSDictionary *)eventAttribute){

    SEIAPEventAttribute *attribute = [SolarengineEventAttribute iapEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackIAPWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackAppAttrWithAttributes:(NSDictionary *)eventAttribute){
    SEAppAttrEventAttribute *attribute = [SolarengineEventAttribute appAttrEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackAppAttrWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackOrderWithAttributes:(NSDictionary *)eventAttribute){

    SEOrderEventAttribute *attribute = [SolarengineEventAttribute orderEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackOrderWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackRegisterWithAttributes:(NSDictionary *)eventAttribute){

    SERegisterEventAttribute *attribute = [SolarengineEventAttribute registerEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackRegisterWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackLoginWithAttributes:(NSDictionary *)eventAttribute){

    SELoginEventAttribute *attribute = [SolarengineEventAttribute loginEventAttribute:eventAttribute];
    [[SolarEngineSDK sharedInstance] trackLoginWithAttributes:attribute];
}
RCT_EXPORT_METHOD(trackCustomEvent:(NSString *)eventName
                    customProperties:(NSDictionary *)customProperties
                    presetProperties:(NSDictionary *)presetProperties){
    [[SolarEngineSDK sharedInstance] track:eventName 
            withCustomProperties:customProperties 
            withPresetProperties:presetProperties];
}
RCT_EXPORT_METHOD(eventStart:(NSString *)eventName){
    [[SolarEngineSDK sharedInstance] eventStart:eventName];
}
RCT_EXPORT_METHOD(eventEnd:(NSString *)eventName
                properties:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] eventFinish:eventName properties:properties];
}
RCT_EXPORT_METHOD(trackFirstEvent:(NSString *)firstCheckId
                    eventAttribute:(NSDictionary *)eventAttribute ){
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  NSString *log = [NSString stringWithFormat:@"firstCheckId:  %@",firstCheckId];
  [SolarengineAnalysisReactNative log:log method:_cmd];
  log = [NSString stringWithFormat:@"eventAttribute:  %@",eventAttribute];
  [SolarengineAnalysisReactNative log:log method:_cmd];

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {
        
        if ([eventAttribute[@"sdk_inner_type"] isKindOfClass:[NSString class]]) {
            NSString *sdk_inner_type = eventAttribute[@"sdk_inner_type"];

            SEEventBaseAttribute *attribute = nil;
            if ([sdk_inner_type isEqualToString:@"Custom"]){
                attribute = [SolarengineEventAttribute customEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"AdImpression"]){
                attribute = [SolarengineEventAttribute adImpressionEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"AdClick"]){
                attribute = [SolarengineEventAttribute adClickEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"IAP"]){                
                attribute = [SolarengineEventAttribute iapEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"AppAttr"]){
                attribute = [SolarengineEventAttribute appAttrEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"Order"]){
                attribute = [SolarengineEventAttribute orderEventAttribute:eventAttribute];
            }else if ([sdk_inner_type isEqualToString:@"Register"]){
                attribute = [SolarengineEventAttribute registerEventAttribute:eventAttribute];                
            }else if ([sdk_inner_type isEqualToString:@"Login"]){
                attribute = [SolarengineEventAttribute loginEventAttribute:eventAttribute];
            }else{
                NSString *message = @"eventAttribute invalid";
                NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
                @throw myException;
            }
            /*            
            "Custom","AdImpression","AdClick","IAP","AppAttr","Order","Register","Login"
            */
            attribute.firstCheckId = firstCheckId;
            [[SolarEngineSDK sharedInstance] trackFirstEvent:attribute];
        }
    }    
}

RCT_EXPORT_METHOD(userPropertiesInit:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] userInit:properties];
}
RCT_EXPORT_METHOD(userPropertiesUpdate:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] userUpdate:properties];
}
RCT_EXPORT_METHOD(userPropertiesAdd:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] userAdd:properties];
}
RCT_EXPORT_METHOD(userPropertiesUnset:(NSArray *)properties){
    NSArray *_properties = [RCTConvert NSArray:properties];
    [[SolarEngineSDK sharedInstance] userUnset:_properties];
}
RCT_EXPORT_METHOD(userPropertiesAppend:(NSDictionary *)properties){
    [[SolarEngineSDK sharedInstance] userAppend:properties];
}
RCT_EXPORT_METHOD(userPropertiesDelete:(nonnull NSNumber *)deleteType){
/*
SEUserDeleteType
    ByAccountId = 1,
    ByVisitorId = 2
*/
    if ([deleteType isKindOfClass:[NSNumber class]]) {
        int _deleteType = [deleteType intValue];
        SEUserDeleteType type;
        if (_deleteType == 1){
            type = SEUserDeleteTypeByAccountId;
        }else if (_deleteType == 2){
            type = SEUserDeleteTypeByVisitorId;
        }else{
            NSString *message = @"deleteType  Invalid";
            NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
            @throw myException;
        }

        [[SolarEngineSDK sharedInstance] userDelete:type];
    }else{
            NSString *message = @"deleteType  Invalid";
            NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
            @throw myException;
    }

}

RCT_EXPORT_METHOD(reportEventimmediately){
    [[SolarEngineSDK sharedInstance] reportEventImmediately];
}

RCT_EXPORT_METHOD(trackAppReEngagement:(NSDictionary *)customProperties){

    [[SolarEngineSDK sharedInstance] trackAppReEngagement:customProperties];
}

RCT_EXPORT_METHOD(appDeeplinkOpenURL:(NSString *)urlString){

  NSURL *url = [NSURL URLWithString:urlString];
  [[SolarEngineSDK sharedInstance] appDeeplinkOpenURL:url];
}

RCT_EXPORT_METHOD(requestTrackingAuthorization:(RCTResponseSenderBlock)completionHandler){

    [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

    [[SolarEngineSDK sharedInstance] requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
        completionHandler(@[@(status)]);
    }];
}


- (BOOL)isSKANApiAvailable{
  
  Class cls = NSClassFromString(@"SKAdNetwork");
  SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:completionHandler:");

  if (cls == nil) {
      return NO;
  }
  if (!selector) {
      return NO;
  }
  if ([cls respondsToSelector:selector] == NO) {
      return NO;
  }
  return YES;
}

-(NSDictionary *)convertError2Dict:(NSError *)error{

  if (error == nil) {
    return  [NSDictionary new];
  }
  NSMutableDictionary *dict = [NSMutableDictionary new];
  if (error.localizedDescription) {
    [dict setObject:error.localizedDescription forKey:@"localizedDescription"];
  }
  [dict setObject:@(error.code) forKey:@"code"];
  return dict;
}


extern NSString *const SKAdNetworkCoarseConversionValueHigh;
extern NSString *const SKAdNetworkCoarseConversionValueLow;
extern NSString *const SKAdNetworkCoarseConversionValueMedium;
NSString *const SKAdNetworkCoarseConversionValueHigh = @"high";
NSString *const SKAdNetworkCoarseConversionValueLow = @"low";
NSString *const SKAdNetworkCoarseConversionValueMedium = @"medium";

RCT_EXPORT_METHOD(updatePostbackConversionValue:(int)type
                                conversionValue:(int)conversionValue
                                    coarseValue:(NSString *)coarseValue
                                     lockWindow:(nonnull NSNumber *)lockWindow
                                     completionHandler:(RCTResponseSenderBlock)completion
                                     ){
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  [SolarengineAnalysisReactNative log:[NSString stringWithFormat:@"coarseValue: %@", coarseValue] method:_cmd];

  NSString *_coarseValue = @"";

    if (@available(iOS 16.1, *)) {
#if __has_include(<StoreKit/SKAdNetwork.h>)
      BOOL avaiable = [self isSKANApiAvailable];
      if (avaiable) {
        if ([coarseValue isEqualToString:@"High"]){
          _coarseValue = SKAdNetworkCoarseConversionValueHigh;
        }else if([coarseValue isEqualToString:@"Low"]){
          _coarseValue = SKAdNetworkCoarseConversionValueLow;
        }else if([coarseValue isEqualToString:@"Medium"]){
          _coarseValue = SKAdNetworkCoarseConversionValueMedium;
        }
        NSString *log = [NSString stringWithFormat:@"_coarseValue: %@",_coarseValue];
        [SolarengineAnalysisReactNative log:log method:_cmd];
      }
#else
      ;
#endif


      BOOL hasConversionValue = NO;//1
      BOOL hasCoarseValue = NO;//2
      BOOL hasLockWindow = NO;//4
        // int eventType = [_eventType intValue];
      if ((type & 1) == 1) {
        hasConversionValue = YES;
        [SolarengineAnalysisReactNative log:@"got conversionValue" method:_cmd];
      }
      if ((type & 2) == 2) {
        hasCoarseValue = YES;
        [SolarengineAnalysisReactNative log:@"got coarseValue" method:_cmd];
      }
      if ((type & 4) == 4) {
        hasLockWindow = YES;
        [SolarengineAnalysisReactNative log:@"got lockWindow" method:_cmd];
      }

        if (hasLockWindow){
          if(lockWindow && [lockWindow isKindOfClass:[NSNumber class]]){
            
            BOOL _lockWindow = [lockWindow boolValue];
            [[SolarEngineSDK sharedInstance] updatePostbackConversionValue:conversionValue
                                                               coarseValue:_coarseValue
                                                                lockWindow:_lockWindow completionHandler:^(NSError * _Nonnull error) {
              
              NSString *log = @"success";
              if (error) {
                log = [NSString stringWithFormat:@"error: %@",error];
              }
              log = [NSString stringWithFormat:@"updatePostbackConversionValue%@  ",log];
              [SolarengineAnalysisReactNative log:log method:_cmd];
              
              if(completion){
                completion(@[[self convertError2Dict:error]]);
              }
            }];
          }else{
            NSString *errMsg = @"lockWindow invalid";
            [SolarengineAnalysisReactNative logErrorMsg:errMsg method:_cmd];
              if(completion){
                NSError *error = [NSError errorWithDomain:@"com.solarenigne.bridge" code:-1 userInfo:@{@"NSLocalizedDescription":errMsg}];
                completion(@[[self convertError2Dict:error]]);
              }
          }
        }else{
          [SolarengineAnalysisReactNative log:@"no lockWindow" method:_cmd];

            [[SolarEngineSDK sharedInstance] updatePostbackConversionValue:conversionValue
                coarseValue:_coarseValue
                completionHandler:^(NSError * _Nonnull error) {

              NSString *log = @"success";
              if (error) {
                log = [NSString stringWithFormat:@"error: %@",error];
              }
              log = [NSString stringWithFormat:@"updatePostbackConversionValue%@  ",log];
              [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

                if(completion){
                  completion(@[[self convertError2Dict:error]]);
                }
            }];
        }

        return;
    } 

    [[SolarEngineSDK sharedInstance] updatePostbackConversionValue:conversionValue completionHandler:^(NSError * _Nonnull error) {
        NSString *log = @"success";
        if (error) {
          log = [NSString stringWithFormat:@"error: %@",error];
        }
        log = [NSString stringWithFormat:@"updatePostbackConversionValue%@  ",log];
        [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

      if(completion){
          completion(@[[self convertError2Dict:error]]);
        }
    }];

}


// MARK: - Remote Configs
RCT_EXPORT_METHOD(setDefaultConfig:(NSArray *)configslist){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  NSString *log = [NSString stringWithFormat:@"invoked, configslist %@",configslist];
  [SolarengineAnalysisReactNative log:log method:_cmd];

  NSMutableArray *list = [NSMutableArray new];
  for (NSDictionary *dict in configslist) {
    int type = [[dict objectForKey:@"type"] intValue];
    if (type == 4) {
      @try {
        NSError *error = nil;
        NSString *value = [NSString stringWithFormat:@"%@",[dict objectForKey:@"value"]];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
          NSString *log = [NSString stringWithFormat:@"Error converting string to JSONObject: %@", error];
          [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];
        } else {

          NSMutableDictionary *tempDict = [NSMutableDictionary new];
          [tempDict addEntriesFromDictionary:dict];
          [tempDict setObject:jsonObject forKey:@"value"];

          [list addObject:tempDict];
        }
      } @catch (NSException *exception) {

      }@finally {
      }

    }else{
      [list addObject:dict];
    }
  }
  [[SESDKRemoteConfig sharedInstance] setDefaultConfig:list];

#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}
RCT_EXPORT_METHOD(setRemoteConfigEventProperties:(NSDictionary *)properties ){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  [[SESDKRemoteConfig sharedInstance] setRemoteConfigEventProperties:properties];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}
RCT_EXPORT_METHOD(setRemoteConfigUserProperties:(NSDictionary *)properties){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  [[SESDKRemoteConfig sharedInstance] setRemoteConfigUserProperties:properties];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}
/*
 这里将RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 改为了RCT_EXPORT_METHOD的原因:
 在rn侧,先调用后者再紧跟着调用前者, 会发现在bridge层先调用了前者 然后调用了后者,不符合逻辑
 */
//RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fastFetchRemoteConfigWithKey:(NSString *)key){
RCT_EXPORT_METHOD(fastFetchRemoteConfigWithKey:(NSString *)key
                                       completionHandler:(RCTResponseSenderBlock)completion){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)

  id data = [[SESDKRemoteConfig sharedInstance] fastFetchRemoteConfig:key];
  NSString *log = [NSString stringWithFormat:@"invoked,key: %@  value: %@",key,data];
  [SolarengineAnalysisReactNative log:log method:_cmd];

  if (completion) {
    if (data) {
      completion(@[data]);
    }else{
      completion(@[]);
    }
  }
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];
  if (completion) {
      completion(@[]);
  }
#endif
}
RCT_EXPORT_METHOD(fastFetchRemoteConfig:(RCTResponseSenderBlock)completion){

#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)

  NSDictionary *allData = [[SESDKRemoteConfig sharedInstance] fastFetchRemoteConfig];
  NSString *log = [NSString stringWithFormat:@"invoked configs: %@",allData];
  [SolarengineAnalysisReactNative log:log method:_cmd];

  if (completion) {
    if (allData) {
      completion(@[allData]);
    }else{
      completion(@[]);
    }
  }
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];
  if (completion) {
      completion(@[]);
  }
#endif
}
RCT_EXPORT_METHOD(asyncFetchRemoteConfigWithKey:(NSString *)key
                                     completionHandler:(RCTResponseSenderBlock)completion
                  ){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  
  NSString *log = [NSString stringWithFormat:@"invoked, key: %@",key];
  [SolarengineAnalysisReactNative log:log method:_cmd];

  [[SESDKRemoteConfig sharedInstance] asyncFetchRemoteConfig:key completionHandler:^(id  _Nonnull data) {

    NSString *log = [NSString stringWithFormat:@"%@ : %@",key,data];
    [SolarengineAnalysisReactNative log:log method:_cmd];
    if (completion) {
      if (data) {
        completion(@[data]);
      }else{
        completion(@[]);
      }
    }
  }];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];
  if (completion) {
      completion(@[]);
  }
#endif
}

RCT_EXPORT_METHOD(asyncFetchRemoteConfig:(RCTResponseSenderBlock)completion){
  
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  [[SESDKRemoteConfig sharedInstance] asyncFetchRemoteConfigWithCompletionHandler:^(NSDictionary * _Nonnull dict) {
    NSString *log = [NSString stringWithFormat:@"dict: %@",dict];
    [SolarengineAnalysisReactNative log:log method:_cmd];
    if (completion) {
      if (dict) {
        completion(@[dict]);
      }else{
        completion(@[]);
      }
    }
   }];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}



@end
