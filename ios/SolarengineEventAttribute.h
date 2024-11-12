//
//  SolarengineEventAttribute.h
//  SolarEngineSDKSample
//
//  Created by zhanghulk on 2024/9/25.
//

#import <Foundation/Foundation.h>
#import <SolarEngineSDK/SEEventConstants.h>

NS_ASSUME_NONNULL_BEGIN

@interface SolarengineEventAttribute : NSObject

+(SECustomEventAttribute *)customEventAttribute:(NSDictionary *)eventAttribute;

+(SEAdImpressionEventAttribute *)adImpressionEventAttribute:(NSDictionary *)eventAttribute;

+(SEAdClickEventAttribute *)adClickEventAttribute:(NSDictionary *)eventAttribute;

+(SEIAPEventAttribute *)iapEventAttribute:(NSDictionary *)eventAttribute;

+(SEAppAttrEventAttribute *)appAttrEventAttribute:(NSDictionary *)eventAttribute;

+(SEOrderEventAttribute *)orderEventAttribute:(NSDictionary *)eventAttribute;

+(SERegisterEventAttribute *)registerEventAttribute:(NSDictionary *)eventAttribute;

+(SELoginEventAttribute *)loginEventAttribute:(NSDictionary *)eventAttribute;

@end

NS_ASSUME_NONNULL_END
