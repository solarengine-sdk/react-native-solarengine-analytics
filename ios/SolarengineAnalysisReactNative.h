
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNSolarengineAnalysisReactNativeSpec.h"

@interface SolarengineAnalysisReactNative : NSObject <NativeSolarengineAnalysisReactNativeSpec>
#else
#import <React/RCTBridgeModule.h>

@interface SolarengineAnalysisReactNative : NSObject <RCTBridgeModule>
#endif

@end
