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

- (NSNumber *)_multiply:(double)a b:(double)b {
  NSNumber *result = @(a * b);
  
  return result;
}


#ifdef RCT_NEW_ARCH_ENABLED
- (NSNumber *)multiply:(double)a b:(double)b {
  return [self _multiply:a b:b];
}
#else
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  NSNumber *result = [self _multiply:a b:b];
  resolve(result);
}
#endif


#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeSolarengineAnalysisReactNativeSpecJSI>(params);
}
#else
;
#endif


#pragma mark - SolarEngine

-(void)_setReactNativeBridgeVersion:(NSString *)version{
  
  NSString *log = [NSString stringWithFormat:@"version: %@",version];
  [SolarengineAnalysisReactNative log:log method:_cmd];
  
  SEWrapperManager *wrapper = [SEWrapperManager sharedInstance];
  wrapper.sub_lib_version = [NSString stringWithFormat:@"%@",version];
  wrapper.sdk_type = @"reactnative";
}

#ifdef RCT_NEW_ARCH_ENABLED
-(void)setReactNativeBridgeVersion:(NSString *)version{
  [self _setReactNativeBridgeVersion:version];
}
#else
RCT_EXPORT_METHOD(setReactNativeBridgeVersion:(NSString *)version)
{
  [self _setReactNativeBridgeVersion:version];
}
#endif


// MARK: - preInit
- (void)_preInit:(NSString *)appKey {
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  
  if (appKey == nil) {
    NSString *message = @"appKey can`t be nil";
    [SolarengineAnalysisReactNative logErrorMsg:message method:_cmd];
    NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:nil];
    @throw myException;
  }
  [[SolarEngineSDK sharedInstance] preInitWithAppKey:appKey];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)preInit:(NSString *)appKey {
  [self _preInit:appKey];
}
#else
RCT_EXPORT_METHOD(preInit:(NSString *)appKey) {
  [self _preInit:appKey];
}
#endif

// MARK: - initialize
- (void)_initialize:(NSString *)appKey config:(NSDictionary *)config remoteConfig:(NSDictionary *)remoteConfig customDomain:(NSDictionary *)customDomain {
  
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  
  if (appKey == nil) {
    NSString *message = @"appKey can`t be nil";
    [SolarengineAnalysisReactNative logErrorMsg:message method:_cmd];
    NSException *myException = [NSException exceptionWithName:@"Invalid Params" reason:message userInfo:
                                nil];
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
  
  BOOL enableDeferredDeeplink = NO;
  if (config[@"enableDeferredDeeplink"]) {
    enableDeferredDeeplink = [config[@"enableDeferredDeeplink"] boolValue];
    seconfig.enableDelayDeeplink = enableDeferredDeeplink;
  }
  
  [SolarengineAnalysisReactNative log:config method:_cmd];
  [[SolarEngineSDK sharedInstance] startWithAppKey:appKey config:seconfig];
}


#ifdef RCT_NEW_ARCH_ENABLED
- (void)initialize:(NSString *)appKey config:(NSDictionary *)config remoteConfig:(NSDictionary *)remoteConfig customDomain:(NSDictionary *)customDomain {
  [self _initialize:appKey config:config remoteConfig:remoteConfig customDomain:customDomain];
}
#else
RCT_EXPORT_METHOD(initialize:(NSString *)appKey
                  config:(NSDictionary *)config
                  remoteConfig:(NSDictionary *)remoteConfig
                  customDomain:(NSDictionary *)customDomain) {
  [self _initialize:appKey config:config remoteConfig:remoteConfig customDomain:customDomain];
}
#endif


// MARK: - registerInitiateComplete
- (void)_registerInitiateComplete:(RCTResponseSenderBlock)callback {
  if(callback == nil) return;
  [[SolarEngineSDK sharedInstance] setInitCompletedCallback:^(int code) {
    [SolarengineAnalysisReactNative log:[NSString stringWithFormat:@"SDK init result code = %d",code] method:_cmd];
    if(callback) {
      int result = code;
      callback(@[@(result)]);
    }
  }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)registerInitiateComplete:(RCTResponseSenderBlock)callback {
  [self _registerInitiateComplete:callback];
}
#else
RCT_EXPORT_METHOD(registerInitiateComplete:(RCTResponseSenderBlock)callback) {
  [self _registerInitiateComplete:callback];
}
#endif

// MARK: - registerAttribution
- (void)_registerAttribution:(RCTResponseSenderBlock)callback {
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  if(callback == nil) return;
  [[SolarEngineSDK sharedInstance] setAttributionCallback:^(int code, NSDictionary * _Nullable attributionData) {
    NSString *log = [NSString stringWithFormat:@"attribution code: %d",code];
    [SolarengineAnalysisReactNative log:log method:_cmd];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    if (attributionData) {
      [result setObject:attributionData forKey:@"reactnative_data"];
    }
    [result setObject:@(code) forKey:@"reactnative_code"];
    if(callback) {
      callback(@[result]);
    }
  }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)registerAttribution:(RCTResponseSenderBlock)callback {
  [self _registerAttribution:callback];
}
#else
RCT_EXPORT_METHOD(registerAttribution:(RCTResponseSenderBlock)callback) {
  [self _registerAttribution:callback];
}
#endif



- (void)_registerDeeplink:(RCTResponseSenderBlock)deeplink{
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
#ifdef RCT_NEW_ARCH_ENABLED
- (void)registerDeeplink:(RCTResponseSenderBlock)callback{
  [self _registerDeeplink:callback];
}
#else
RCT_EXPORT_METHOD(registerDeeplink:(RCTResponseSenderBlock)deeplink){
  [self _registerDeeplink:deeplink];
}
#endif




- (void)_registerDeferredDeeplink:(RCTResponseSenderBlock)deferredDeeplink{
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  
  if(deferredDeeplink == nil){
    return;
  }
  //  setDe layDeeplinkDeepLinkCallbackWithSuccess // before 1.3.0.0
  //  setDe layDeepLinkCallbackWithSuccess // from 1.3.0.0 to 1.3.0.1 
  //  setDe ferredDeepLinkCallbackWithSuccess  // from 1.3.0.3
  
  [[SolarEngineSDK sharedInstance] setDeferredDeepLinkCallbackWithSuccess:^(SEDeferredDeeplinkInfo * _Nullable deeplinkInfo) {
    
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
    if(deferredDeeplink){
      deferredDeeplink(@[result]);
    }
  } fail:^(NSError * _Nullable error) {
    
    [SolarengineAnalysisReactNative logErrorMsg:error method:_cmd];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    [result setObject:@(error.code) forKey:@"reactnative_code"];
    if(deferredDeeplink){
      deferredDeeplink(@[result]);
    }
  }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)registerDeferredDeeplink:(RCTResponseSenderBlock)callback{
  [self _registerDeferredDeeplink:callback];
}
#else
RCT_EXPORT_METHOD(registerDeferredDeeplink:(RCTResponseSenderBlock)deferredDeeplink){
  [self _registerDeferredDeeplink:deferredDeeplink];
}
#endif

// MARK: - trackAdImpressionWithAttributes
- (void)_trackAdImpressionWithAttributes:(NSDictionary *)eventAttribute {
  SEAdImpressionEventAttribute *attribute = [SolarengineEventAttribute adImpressionEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackAdImpressionWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackAdImpressionWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackAdImpressionWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackAdImpressionWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackAdImpressionWithAttributes:eventAttribute];
}
#endif

// MARK: - trackAdClickWithAttributes
- (void)_trackAdClickWithAttributes:(NSDictionary *)eventAttribute {
  SEAdClickEventAttribute *attribute = [SolarengineEventAttribute adClickEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackAdClickWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackAdClickWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackAdClickWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackAdClickWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackAdClickWithAttributes:eventAttribute];
}
#endif

// MARK: - trackIAPWithAttributes
- (void)_trackIAPWithAttributes:(NSDictionary *)eventAttribute {
  SEIAPEventAttribute *attribute = [SolarengineEventAttribute iapEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackIAPWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackIAPWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackIAPWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackIAPWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackIAPWithAttributes:eventAttribute];
}
#endif

// MARK: - trackAppAttrWithAttributes
- (void)_trackAppAttrWithAttributes:(NSDictionary *)eventAttribute {
  SEAppAttrEventAttribute *attribute = [SolarengineEventAttribute appAttrEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackAppAttrWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackAppAttrWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackAppAttrWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackAppAttrWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackAppAttrWithAttributes:eventAttribute];
}
#endif

// MARK: - trackOrderWithAttributes
- (void)_trackOrderWithAttributes:(NSDictionary *)eventAttribute {
  SEOrderEventAttribute *attribute = [SolarengineEventAttribute orderEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackOrderWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackOrderWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackOrderWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackOrderWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackOrderWithAttributes:eventAttribute];
}
#endif

// MARK: - trackRegisterWithAttributes
- (void)_trackRegisterWithAttributes:(NSDictionary *)eventAttribute {
  SERegisterEventAttribute *attribute = [SolarengineEventAttribute registerEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackRegisterWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackRegisterWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackRegisterWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackRegisterWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackRegisterWithAttributes:eventAttribute];
}
#endif

// MARK: - trackLoginWithAttributes
- (void)_trackLoginWithAttributes:(NSDictionary *)eventAttribute {
  SELoginEventAttribute *attribute = [SolarengineEventAttribute loginEventAttribute:eventAttribute];
  [[SolarEngineSDK sharedInstance] trackLoginWithAttributes:attribute];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackLoginWithAttributes:(NSDictionary *)eventAttribute {
  [self _trackLoginWithAttributes:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackLoginWithAttributes:(NSDictionary *)eventAttribute) {
  [self _trackLoginWithAttributes:eventAttribute];
}
#endif

// MARK: - trackCustomEvent
- (void)_trackCustomEvent:(NSString *)eventName customProperties:(NSDictionary *)customProperties presetProperties:(NSDictionary *)presetProperties {
  [[SolarEngineSDK sharedInstance] track:eventName
                    withCustomProperties:customProperties
                    withPresetProperties:presetProperties];
}

#ifdef RCT_NEW_ARCH_ENABLED
//- (void)trackCustomEvent:(NSString *)eventName customProperties:(NSDictionary *)customProperties presetProperties:(NSDictionary *)presetProperties {
- (void)trackCustomEvent:(nonnull NSString *)eventName customProperties:(nonnull NSDictionary *)customProperties preProperties:(nonnull NSDictionary *)preProperties {
  [self _trackCustomEvent:eventName customProperties:customProperties presetProperties:preProperties];
}
#else
RCT_EXPORT_METHOD(trackCustomEvent:(NSString *)eventName customProperties:(NSDictionary *)customProperties preProperties:(NSDictionary *)preProperties) {
  [self _trackCustomEvent:eventName customProperties:customProperties presetProperties:preProperties];
}
#endif

// MARK: - eventStart
- (void)_eventStart:(NSString *)eventName {
  [[SolarEngineSDK sharedInstance] eventStart:eventName];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)eventStart:(NSString *)eventName {
  [self _eventStart:eventName];
}
#else
RCT_EXPORT_METHOD(eventStart:(NSString *)eventName) {
  [self _eventStart:eventName];
}
#endif

// MARK: - eventEnd
- (void)_eventEnd:(NSString *)eventName properties:(NSDictionary *)properties {
  [[SolarEngineSDK sharedInstance] eventFinish:eventName properties:properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)eventEnd:(NSString *)eventName properties:(NSDictionary *)properties {
  [self _eventEnd:eventName properties:properties];
}
#else
RCT_EXPORT_METHOD(eventEnd:(NSString *)eventName properties:(NSDictionary *)properties) {
  [self _eventEnd:eventName properties:properties];
}
#endif

// MARK: - trackFirstEvent
- (void)_trackFirstEvent:(NSString *)firstCheckId eventAttribute:(NSDictionary *)eventAttribute {
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
      attribute.firstCheckId = firstCheckId;
      [[SolarEngineSDK sharedInstance] trackFirstEvent:attribute];
    }
  }
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackFirstEvent:(NSString *)firstCheckId eventAttribute:(NSDictionary *)eventAttribute {
  [self _trackFirstEvent:firstCheckId eventAttribute:eventAttribute];
}
#else
RCT_EXPORT_METHOD(trackFirstEvent:(NSString *)firstCheckId eventAttribute:(NSDictionary *)eventAttribute) {
  [self _trackFirstEvent:firstCheckId eventAttribute:eventAttribute];
}
#endif

// MARK: - userPropertiesInit
- (void)_userPropertiesInit:(NSDictionary *)properties {
  [[SolarEngineSDK sharedInstance] userInit:properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesInit:(NSDictionary *)properties {
  [self _userPropertiesInit:properties];
}
#else
RCT_EXPORT_METHOD(userPropertiesInit:(NSDictionary *)properties) {
  [self _userPropertiesInit:properties];
}
#endif

// MARK: - userPropertiesUpdate
- (void)_userPropertiesUpdate:(NSDictionary *)properties {
  [[SolarEngineSDK sharedInstance] userUpdate:properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesUpdate:(NSDictionary *)properties {
  [self _userPropertiesUpdate:properties];
}
#else
RCT_EXPORT_METHOD(userPropertiesUpdate:(NSDictionary *)properties) {
  [self _userPropertiesUpdate:properties];
}
#endif

// MARK: - userPropertiesAdd
- (void)_userPropertiesAdd:(NSDictionary *)properties {
  [[SolarEngineSDK sharedInstance] userAdd:properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesAdd:(NSDictionary *)properties {
  [self _userPropertiesAdd:properties];
}
#else
RCT_EXPORT_METHOD(userPropertiesAdd:(NSDictionary *)properties) {
  [self _userPropertiesAdd:properties];
}
#endif

// MARK: - userPropertiesUnset
- (void)_userPropertiesUnset:(NSArray *)properties {
  NSArray *_properties = [RCTConvert NSArray:properties];
  [[SolarEngineSDK sharedInstance] userUnset:_properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesUnset:(NSArray *)properties {
  [self _userPropertiesUnset:properties];
}
#else
RCT_EXPORT_METHOD(userPropertiesUnset:(NSArray *)properties) {
  [self _userPropertiesUnset:properties];
}
#endif

// MARK: - userPropertiesAppend
- (void)_userPropertiesAppend:(NSDictionary *)properties {
  [[SolarEngineSDK sharedInstance] userAppend:properties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesAppend:(NSDictionary *)properties {
  [self _userPropertiesAppend:properties];
}
#else
RCT_EXPORT_METHOD(userPropertiesAppend:(NSDictionary *)properties) {
  [self _userPropertiesAppend:properties];
}
#endif

// MARK: - userPropertiesDelete
- (void)_userPropertiesDelete:(nonnull NSNumber *)deleteType {
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

#ifdef RCT_NEW_ARCH_ENABLED
- (void)userPropertiesDelete:(double)deleteType {
  int dt = (int)deleteType;
  
  [self _userPropertiesDelete:[NSNumber numberWithInt:dt]];
}
#else
RCT_EXPORT_METHOD(userPropertiesDelete:(nonnull NSNumber *)deleteType) {
  [self _userPropertiesDelete:deleteType];
}
#endif

// MARK: - reportEventimmediately
- (void)_reportEventimmediately {
  [[SolarEngineSDK sharedInstance] reportEventImmediately];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)reportEventimmediately {
  [self _reportEventimmediately];
}
#else
RCT_EXPORT_METHOD(reportEventimmediately) {
  [self _reportEventimmediately];
}
#endif

// MARK: - trackAppReEngagement
- (void)_trackAppReEngagement:(NSDictionary *)customProperties {
  [[SolarEngineSDK sharedInstance] trackAppReEngagement:customProperties];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)trackAppReEngagement:(NSDictionary *)customProperties {
  [self _trackAppReEngagement:customProperties];
}
#else
RCT_EXPORT_METHOD(trackAppReEngagement:(NSDictionary *)customProperties) {
  [self _trackAppReEngagement:customProperties];
}
#endif

// MARK: - appDeeplinkOpenURL
- (void)_appDeeplinkOpenURL:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  [[SolarEngineSDK sharedInstance] appDeeplinkOpenURL:url];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)appDeeplinkOpenURL:(NSString *)urlString {
  [self _appDeeplinkOpenURL:urlString];
}
#else
RCT_EXPORT_METHOD(appDeeplinkOpenURL:(NSString *)urlString) {
  [self _appDeeplinkOpenURL:urlString];
}
#endif

// MARK: - requestTrackingAuthorization
- (void)_requestTrackingAuthorization:(RCTResponseSenderBlock)completionHandler {
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];
  [[SolarEngineSDK sharedInstance] requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
    completionHandler(@[@(status)]);
  }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)requestTrackingAuthorization:(RCTResponseSenderBlock)completionHandler {
  [self _requestTrackingAuthorization:completionHandler];
}
#else
RCT_EXPORT_METHOD(requestTrackingAuthorization:(RCTResponseSenderBlock)completionHandler) {
  [self _requestTrackingAuthorization:completionHandler];
}
#endif

// MARK: - updatePostbackConversionValue
//RCT_EXPORT_METHOD(updatePostbackConversionValue:(int)type
//                                conversionValue:(int)conversionValue
//                                    coarseValue:(NSString *)coarseValue
//                                     lockWindow:(nonnull NSNumber *)lockWindow
//                                     completionHandler:(RCTResponseSenderBlock)completion
//                                     ){
- (void)_updatePostbackConversionValue:(double)value conversionValue:(double)conversionValue coarseValue:(NSString *)coarseValue lockWindow:(nonnull NSNumber *)lockWindow callback:(RCTResponseSenderBlock)completion {
  int type = (int)value;
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

#ifdef RCT_NEW_ARCH_ENABLED
- (void)updatePostbackConversionValue:(double)type conversionValue:(double)conversionValue coarseValue:(NSString *)coarseValue lockWindow:(BOOL)lockWindow callback:(RCTResponseSenderBlock)callback {
  NSNumber *lw = [NSNumber numberWithBool:lockWindow];
  [self _updatePostbackConversionValue:type conversionValue:conversionValue coarseValue:coarseValue lockWindow:lw callback:callback];
}
#else
RCT_EXPORT_METHOD(updatePostbackConversionValue:(double)type conversionValue:(double)conversionValue coarseValue:(NSString *)coarseValue lockWindow:(BOOL)lockWindow callback:(RCTResponseSenderBlock)callback) {
  
  NSNumber *lw = [NSNumber numberWithBool:lockWindow];
  [self _updatePostbackConversionValue:type conversionValue:conversionValue coarseValue:coarseValue lockWindow:lw callback:callback];
}
#endif


- (NSDictionary *)_retrieveAttribution {
  NSDictionary *retrieveAttribution = [[SolarEngineSDK sharedInstance] getAttributionData];
  return retrieveAttribution;
}
#ifdef RCT_NEW_ARCH_ENABLED
- (NSDictionary *)retrieveAttribution {
  return [self _retrieveAttribution];
}
#else
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(retrieveAttribution){
  return [self _retrieveAttribution];
}
#endif

#pragma mark - missing
- (NSString *)_fetchDistinctId {
  NSString *distinctId =  [[SolarEngineSDK sharedInstance] getDistinctId];
  return distinctId;
}
#ifdef RCT_NEW_ARCH_ENABLED
- (NSString *)fetchDistinctId {
  return [self _fetchDistinctId];
}
#else
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchDistinctId){
  return [self _fetchDistinctId];
}
#endif

-(void)_setVisitorID:(NSString *)visitorID{
  [[SolarEngineSDK sharedInstance] setVisitorID:visitorID];
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)setVisitorID:(NSString *)visitorID{
  [self _setVisitorID:visitorID];
}
#else
RCT_EXPORT_METHOD(setVisitorID:(NSString *)visitorID){
  [self _setVisitorID:visitorID];
}
#endif


-(NSString *)_fetchVisitor{
  NSString *visitorId = [[SolarEngineSDK sharedInstance] visitorID];
  return visitorId;
}
#ifdef RCT_NEW_ARCH_ENABLED
-(NSString *)fetchVisitor{
  return [self _fetchVisitor];
}
#else
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchVisitor){
  return [self _fetchVisitor];
}
#endif


-(void)_login:(NSString *)accountID{
  [[SolarEngineSDK sharedInstance] loginWithAccountID:accountID];
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)login:(NSString *)accountID{
  [self _login:accountID];
}
#else
RCT_EXPORT_METHOD(login:(NSString *)accountID){
  [self _login:accountID];
}
#endif


-(void)_logout{
  [[SolarEngineSDK sharedInstance] logout];
}

#ifdef RCT_NEW_ARCH_ENABLED
-(void)logout{
  [self _logout];
}
#else
RCT_EXPORT_METHOD(logout){
  [self _logout];
}
#endif


-(NSString *)_fetchAccount{
  NSString *accountID = [[SolarEngineSDK sharedInstance] accountID];
  return accountID;
}
#ifdef RCT_NEW_ARCH_ENABLED
-(NSString *)fetchAccount{
  return [self _fetchAccount];
}
#else
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fetchAccount){
  return [self _fetchAccount];
}
#endif


-(void)_setSuperProperties:(NSDictionary *)properties{
  [[SolarEngineSDK sharedInstance] setSuperProperties:properties];
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)setSuperProperties:(NSDictionary *)properties{
  [self _setSuperProperties:properties];
}
#else
RCT_EXPORT_METHOD(setSuperProperties:(NSDictionary *)properties){
  [self _setSuperProperties:properties];
}
#endif

-(void)_clearSuperProperties{
  [[SolarEngineSDK sharedInstance] clearSuperProperties];
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)clearSuperProperties{
  [self _clearSuperProperties];
}
#else
RCT_EXPORT_METHOD(clearSuperProperties){
  [self _clearSuperProperties];
}
#endif

-(void)_unsetSuperProperty:(NSString *)key{
  [[SolarEngineSDK sharedInstance] unsetSuperProperty:key];
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)unsetSuperProperty:(NSString *)key{
  [self _unsetSuperProperty:key];
}
#else
RCT_EXPORT_METHOD(unsetSuperProperty:(NSString *)key){
  [self _unsetSuperProperty:key];
}
#endif


-(NSDictionary *)_retrievePresetProperties{
    NSDictionary *properties = [[SolarEngineSDK sharedInstance] getPresetProperties];
    return properties;
}
#ifdef RCT_NEW_ARCH_ENABLED
-(NSDictionary *)retrievePresetProperties{
  return [self _retrievePresetProperties];
}
#else
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(retrievePresetProperties){
  return [self _retrievePresetProperties];
}
#endif


-(void)_setPresetProperties:(int)eventType
                    properties:(NSDictionary *)properties{
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
#ifdef RCT_NEW_ARCH_ENABLED
-(void)setPresetProperties:(NSString *)eventType
                properties:(NSDictionary *)properties{
  int type = [eventType intValue];
  [self _setPresetProperties:type properties:properties];
}
#else
RCT_EXPORT_METHOD(setPresetProperties:(int)eventType
                  properties:(NSDictionary *)properties){
  [self _setPresetProperties:eventType properties:properties];
}
#endif


// MARK: - setGDPRArea
- (void)_setGDPRArea:(BOOL)isGDPR {
    [[SolarEngineSDK sharedInstance] setGDPRArea:isGDPR];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)setGDPRArea:(BOOL)isGDPR {
    [self _setGDPRArea:isGDPR];
}
#else
RCT_EXPORT_METHOD(setGDPRArea:(BOOL)isGDPR) {
    [self _setGDPRArea:isGDPR];
}
#endif

// MARK: - setOaid
- (void)_setOaid:(NSString *)oaid {
  ;
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)setOaid:(NSString *)oaid {
    [self _setOaid:oaid];
}
#else
RCT_EXPORT_METHOD(setOaid:(NSString *)oaid) {
    [self _setOaid:oaid];
}
#endif

// MARK: - setGaid
- (void)_setGaid:(NSString *)gaid {
  ;
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)setGaid:(NSString *)gaid {
    [self _setGaid:gaid];
}
#else
RCT_EXPORT_METHOD(setGaid:(NSString *)gaid) {
    [self _setGaid:gaid];
}
#endif

// MARK: - setChannel
- (void)_setChannel:(NSString *)channel {
  ;
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)setChannel:(NSString *)channel {
    [self _setChannel:channel];
}

#else
RCT_EXPORT_METHOD(setChannel:(NSString *)channel) {
    [self _setChannel:channel];
}
#endif




#pragma mark - Remote Configs
-(void)_setDefaultConfig:(NSArray *)configslist{
//RCT_EXPORT_METHOD(setDefaultConfig:(NSArray *)configslist){
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

#ifdef RCT_NEW_ARCH_ENABLED
-(void)setDefaultConfig:(NSArray *)configslist{
  [self _setDefaultConfig:configslist];
}
#else
RCT_EXPORT_METHOD(setDefaultConfig:(NSArray *)configslist) {
  [self _setDefaultConfig:configslist];
}
#endif

-(void)_setRemoteConfigEventProperties:(NSDictionary *)properties{

//RCT_EXPORT_METHOD(setRemoteConfigEventProperties:(NSDictionary *)properties ){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  [[SESDKRemoteConfig sharedInstance] setRemoteConfigEventProperties:properties];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)setRemoteConfigEventProperties:(NSDictionary *)properties{
    [self _setRemoteConfigEventProperties:properties];
}

#else
RCT_EXPORT_METHOD(setRemoteConfigEventProperties:(NSDictionary *)properties) {
  [self _setRemoteConfigEventProperties:properties];
}
#endif

-(void)_setRemoteConfigUserProperties:(NSDictionary *)properties{
//RCT_EXPORT_METHOD(setRemoteConfigUserProperties:(NSDictionary *)properties){
#if __has_include(<SESDKRemoteConfig/SESDKRemoteConfig.h>)
  [SolarengineAnalysisReactNative log:@"invoked" method:_cmd];

  [[SESDKRemoteConfig sharedInstance] setRemoteConfigUserProperties:properties];
#else
  NSString *log = @"SESDKRemoteConfig SDK is missing";
  [SolarengineAnalysisReactNative logErrorMsg:log method:_cmd];

#endif
}
#ifdef RCT_NEW_ARCH_ENABLED
-(void)setRemoteConfigUserProperties:(NSDictionary *)properties{
    [self _setRemoteConfigUserProperties:properties];
}

#else
RCT_EXPORT_METHOD(setRemoteConfigUserProperties:(NSDictionary *)properties) {
  [self _setRemoteConfigUserProperties:properties];
}
#endif
/*
 这里将RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 改为了RCT_EXPORT_METHOD的原因:
 在rn侧,先调用后者再紧跟着调用前者, 会发现在bridge层先调用了前者 然后调用了后者,不符合逻辑
 */
//RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(fastFetchRemoteConfigWithKey:(NSString *)key){

- (void)_fastFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion {
//-(void)fastFetchRemoteConfigWithKey:(NSString *)key completionHandler:(RCTResponseSenderBlock)completion{
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
#ifdef RCT_NEW_ARCH_ENABLED
- (void)fastFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion {
  [self _fastFetchRemoteConfigWithKey:key callback:completion];
}

#else
RCT_EXPORT_METHOD(fastFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion ) {
  [self _fastFetchRemoteConfigWithKey:key callback:completion];
}
#endif

-(void)_fastFetchRemoteConfig:(RCTResponseSenderBlock)completion{
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
#ifdef RCT_NEW_ARCH_ENABLED
-(void)fastFetchRemoteConfig:(RCTResponseSenderBlock)completion{
  [self _fastFetchRemoteConfig:completion];
}

#else
RCT_EXPORT_METHOD(fastFetchRemoteConfig:(RCTResponseSenderBlock)completion) {
    [self _fastFetchRemoteConfig:completion];
}
#endif

- (void)_asyncFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion {
//-(void)asyncFetchRemoteConfigWithKey:(NSString *)key
//                                     completionHandler:(RCTResponseSenderBlock)completion
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
#ifdef RCT_NEW_ARCH_ENABLED
- (void)asyncFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion {
  [self _asyncFetchRemoteConfigWithKey:key callback:completion];
}

#else
RCT_EXPORT_METHOD(asyncFetchRemoteConfigWithKey:(nonnull NSString *)key callback:(nonnull RCTResponseSenderBlock)completion) {
  [self _asyncFetchRemoteConfigWithKey:key callback:completion];
}
#endif


-(void)_asyncFetchRemoteConfig:(RCTResponseSenderBlock)completion{
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
#ifdef RCT_NEW_ARCH_ENABLED
-(void)asyncFetchRemoteConfig:(RCTResponseSenderBlock)completion{
  [self _asyncFetchRemoteConfig:completion];
}

#else
RCT_EXPORT_METHOD(asyncFetchRemoteConfig:(RCTResponseSenderBlock)completion) {
    [self _asyncFetchRemoteConfig:completion];
}
#endif




// MARK: - Helper Methods
- (BOOL)isSKANApiAvailable {
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

- (NSDictionary *)convertError2Dict:(NSError *)error {
    if (error == nil) {
        return [NSDictionary new];
    }
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (error.localizedDescription) {
        [dict setObject:error.localizedDescription forKey:@"localizedDescription"];
    }
    [dict setObject:@(error.code) forKey:@"code"];
    return dict;
}

// MARK: - Constants
extern NSString *const SKAdNetworkCoarseConversionValueHigh;
extern NSString *const SKAdNetworkCoarseConversionValueLow;
extern NSString *const SKAdNetworkCoarseConversionValueMedium;
NSString *const SKAdNetworkCoarseConversionValueHigh = @"high";
NSString *const SKAdNetworkCoarseConversionValueLow = @"low";
NSString *const SKAdNetworkCoarseConversionValueMedium = @"medium";









@end
