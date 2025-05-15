

#ifdef RCT_NEW_ARCH_ENABLED
#import <SolarengineAnalysisReactNativeSpec/SolarengineAnalysisReactNativeSpec.h>


@interface SolarengineAnalysisReactNative : NSObject <NativeSolarengineAnalysisReactNativeSpec>
#else
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface SolarengineAnalysisReactNative : NSObject <RCTBridgeModule>
#endif

@end
