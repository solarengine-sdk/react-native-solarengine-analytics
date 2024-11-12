//
//  SolarengineEventAttribute.m
//  SolarEngineSDKSample
//
//  Created by zhanghulk on 2024/9/25.
//

#import "SolarengineEventAttribute.h"
#import <SolarEngineSDK/SEEventConstants.h>
#import <React/RCTConvert.h>

NSString * const Alipay                    = @"alipay";
NSString * const Weixin                    = @"weixin";
NSString * const ApplePay                  = @"applepay";
NSString * const Paypal                    = @"paypal";

@implementation SolarengineEventAttribute

+(SECustomEventAttribute *)customEventAttribute:(NSDictionary *)eventAttribute{
    
    SECustomEventAttribute *attribute = nil;
    
    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {
        
        attribute = [[SECustomEventAttribute alloc] init];

        if ([eventAttribute[@"eventName"] isKindOfClass:[NSString class]]) {
            attribute.eventName = eventAttribute[@"eventName"];
        }
        
        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
        
        id receivedObject2 = eventAttribute[@"preProperties"];
        NSDictionary *receivedDict2 = [RCTConvert NSDictionary:receivedObject2];
        if ([receivedDict2 isKindOfClass:[NSDictionary class]]) {
            attribute.presetProperties = receivedDict2;
        }
    }
    return attribute;
}

+(SEAdImpressionEventAttribute *)adImpressionEventAttribute:(NSDictionary *)eventAttribute{
    
    SEAdImpressionEventAttribute *attribute = nil;

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

        attribute = [[SEAdImpressionEventAttribute alloc] init];

        if ([eventAttribute[@"adNetworkPlatform"] isKindOfClass:[NSString class]]) {
            attribute.adNetworkPlatform = eventAttribute[@"adNetworkPlatform"];
        }
        if ([eventAttribute[@"adType"] isKindOfClass:[NSNumber class]]) {
            attribute.adType = [eventAttribute[@"adType"] intValue];
        }
        if ([eventAttribute[@"adNetworkAppID"] isKindOfClass:[NSString class]]) {
            attribute.adNetworkAppID = eventAttribute[@"adNetworkAppID"];
        }
        if ([eventAttribute[@"adNetworkPlacementID"] isKindOfClass:[NSString class]]) {
            attribute.adNetworkPlacementID = eventAttribute[@"adNetworkPlacementID"];
        }
        if ([eventAttribute[@"mediationPlatform"] isKindOfClass:[NSString class]]) {
            attribute.mediationPlatform = eventAttribute[@"mediationPlatform"];
        }
        if ([eventAttribute[@"currency"] isKindOfClass:[NSString class]]) {
            attribute.currency = eventAttribute[@"currency"];
        }

        if ([eventAttribute[@"ecpm"] isKindOfClass:[NSNumber class]]) {
            attribute.ecpm = [eventAttribute[@"ecpm"] doubleValue];
        }
        if (eventAttribute[@"rendered"]) {
            attribute.rendered = [eventAttribute[@"rendered"] boolValue];
        }
        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
    }
    return attribute;
}

+(SEAdClickEventAttribute *)adClickEventAttribute:(NSDictionary *)eventAttribute{
    SEAdClickEventAttribute *attribute = nil;

        if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

            attribute = [[SEAdClickEventAttribute alloc] init];

            if ([eventAttribute[@"adNetworkPlatform"] isKindOfClass:[NSString class]]) {
                attribute.adNetworkPlatform = eventAttribute[@"adNetworkPlatform"];
            }
            if ([eventAttribute[@"adType"] isKindOfClass:[NSNumber class]]) {
                attribute.adType = [eventAttribute[@"adType"] intValue];
            }
            if ([eventAttribute[@"adNetworkPlacementID"] isKindOfClass:[NSString class]]) {
                attribute.adNetworkPlacementID = eventAttribute[@"adNetworkPlacementID"];
            }
            if ([eventAttribute[@"mediationPlatform"] isKindOfClass:[NSString class]]) {
                attribute.mediationPlatform = eventAttribute[@"mediationPlatform"];
            }
            id receivedObject = eventAttribute[@"customProperties"];
            NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
            if ([receivedDict isKindOfClass:[NSDictionary class]]) {
                attribute.customProperties = receivedDict;
            }
        }
    return attribute;
}

+(SEIAPEventAttribute *)iapEventAttribute:(NSDictionary *)eventAttribute{
    
    SEIAPEventAttribute *attribute = nil;

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

        attribute = [[SEIAPEventAttribute alloc] init];

        if ([eventAttribute[@"productID"] isKindOfClass:[NSString class]]) {
            attribute.productID = eventAttribute[@"productID"];
        }
        if ([eventAttribute[@"productName"] isKindOfClass:[NSString class]]) {
            attribute.productName = eventAttribute[@"productName"];
        }
        if ([eventAttribute[@"productCount"] isKindOfClass:[NSNumber class]]) {
            attribute.productCount = [eventAttribute[@"productCount"] intValue];
        }
        if ([eventAttribute[@"orderId"] isKindOfClass:[NSString class]]) {
            attribute.orderId = eventAttribute[@"orderId"];
        }
        if ([eventAttribute[@"payAmount"] isKindOfClass:[NSNumber class]]) {
          attribute.payAmount = [eventAttribute[@"payAmount"] doubleValue];
        }
        if ([eventAttribute[@"currency"] isKindOfClass:[NSString class]]) {
            attribute.currencyType = eventAttribute[@"currency"];
        }

        if ([eventAttribute[@"payType"] isKindOfClass:[NSString class]]) {
            NSString *iapEventPayType = nil;
            NSString *_payType = eventAttribute[@"payType"];
            if ([_payType isEqualToString:Alipay]){
                iapEventPayType = SEIAPEventPayTypeAlipay;
            }else if ([_payType isEqualToString:Weixin]){
                iapEventPayType = SEIAPEventPayTypeWeixin;
            }else if ([_payType isEqualToString:ApplePay]) {
                iapEventPayType = SEIAPEventPayTypeApplePay;
            }else if ([_payType isEqualToString:Paypal]) {
                iapEventPayType = SEIAPEventPayTypePaypal;
            }else{
                iapEventPayType = _payType;
            }
            attribute.payType = iapEventPayType;
        }

        if ([eventAttribute[@"payStatus"] isKindOfClass:[NSNumber class]]) {
            int _payStatus = [eventAttribute[@"payStatus"] intValue];
            attribute.payStatus = (SolarEngineIAPStatus)_payStatus;
        }

        if ([eventAttribute[@"failReason"] isKindOfClass:[NSString class]]) {
            attribute.failReason = eventAttribute[@"failReason"];
        }

        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
    }
    return attribute;
}

+(SEAppAttrEventAttribute *)appAttrEventAttribute:(NSDictionary *)eventAttribute{
    SEAppAttrEventAttribute *attribute = nil;

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

        attribute = [[SEAppAttrEventAttribute alloc] init];

        if ([eventAttribute[@"adNetwork"] isKindOfClass:[NSString class]]) {
            attribute.adNetwork = eventAttribute[@"adNetwork"];
        }
        if ([eventAttribute[@"subChannel"] isKindOfClass:[NSString class]]) {
            attribute.subChannel = eventAttribute[@"subChannel"];
        }
        if ([eventAttribute[@"adAccountID"] isKindOfClass:[NSString class]]) {
            attribute.adAccountID = eventAttribute[@"adAccountID"];
        }
        if ([eventAttribute[@"adAccountName"] isKindOfClass:[NSString class]]) {
            attribute.adAccountName = eventAttribute[@"adAccountName"];
        }
        if ([eventAttribute[@"adCampaignID"] isKindOfClass:[NSString class]]) {
            attribute.adCampaignID = eventAttribute[@"adCampaignID"];
        }
        if ([eventAttribute[@"adCampaignName"] isKindOfClass:[NSString class]]) {
            attribute.adCampaignName = eventAttribute[@"adCampaignName"];
        }
        if ([eventAttribute[@"adOfferID"] isKindOfClass:[NSString class]]) {
            attribute.adOfferID = eventAttribute[@"adOfferID"];
        }
        if ([eventAttribute[@"adOfferName"] isKindOfClass:[NSString class]]) {
            attribute.adOfferName = eventAttribute[@"adOfferName"];
        }
        if ([eventAttribute[@"adCreativeID"] isKindOfClass:[NSString class]]) {
            attribute.adCreativeID = eventAttribute[@"adCreativeID"];
        }
        if ([eventAttribute[@"adCreativeName"] isKindOfClass:[NSString class]]) {
            attribute.adCreativeName = eventAttribute[@"adCreativeName"];
        }
        if ([eventAttribute[@"attributionPlatform"] isKindOfClass:[NSString class]]) {
            attribute.attributionPlatform = eventAttribute[@"attributionPlatform"];
        }

        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
    }
    return attribute;
}

+(SEOrderEventAttribute *)orderEventAttribute:(NSDictionary *)eventAttribute{
    
    SEOrderEventAttribute *attribute = nil;

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

        attribute = [[SEOrderEventAttribute alloc] init];

        if ([eventAttribute[@"orderID"] isKindOfClass:[NSString class]]) {
            attribute.orderID = eventAttribute[@"orderID"];
        }
        if ([eventAttribute[@"payAmount"] isKindOfClass:[NSNumber class]]) {
            attribute.payAmount = [eventAttribute[@"payAmount"] doubleValue];
        }
        if ([eventAttribute[@"currency"] isKindOfClass:[NSString class]]) {
            attribute.currencyType = eventAttribute[@"currency"];
        }
        if ([eventAttribute[@"payType"] isKindOfClass:[NSString class]]) {
            attribute.payType = eventAttribute[@"payType"];
        }
        if ([eventAttribute[@"status"] isKindOfClass:[NSString class]]) {
            attribute.status = eventAttribute[@"status"];/////
        }
        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
    }
    return attribute;
}

+(SERegisterEventAttribute *)registerEventAttribute:(NSDictionary *)eventAttribute{
    SERegisterEventAttribute *attribute = nil;

    if ([eventAttribute isKindOfClass:[NSDictionary class]]) {

        attribute = [[SERegisterEventAttribute alloc] init];

        if ([eventAttribute[@"registerType"] isKindOfClass:[NSString class]]) {
            attribute.registerType = eventAttribute[@"registerType"];
        }
        if ([eventAttribute[@"registerStatus"] isKindOfClass:[NSString class]]) {
            attribute.registerStatus = eventAttribute[@"registerStatus"];
        }

        id receivedObject = eventAttribute[@"customProperties"];
        NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
        if ([receivedDict isKindOfClass:[NSDictionary class]]) {
            attribute.customProperties = receivedDict;
        }
    }
    return attribute;
}

+(SELoginEventAttribute *)loginEventAttribute:(NSDictionary *)eventAttribute{
  SELoginEventAttribute *attribute = nil;
  
  if ([eventAttribute isKindOfClass:[NSDictionary class]]) {
    
    attribute = [[SELoginEventAttribute alloc] init];
    
    if ([eventAttribute[@"loginType"] isKindOfClass:[NSString class]]) {
      attribute.loginType = eventAttribute[@"loginType"];
    }
    if ([eventAttribute[@"loginStatus"] isKindOfClass:[NSString class]]) {
        attribute.loginStatus = eventAttribute[@"loginStatus"];
    }
    
      id receivedObject = eventAttribute[@"customProperties"];
    NSDictionary *receivedDict = [RCTConvert NSDictionary:receivedObject];
    if ([receivedDict isKindOfClass:[NSDictionary class]]) {
      attribute.customProperties = receivedDict;
    }
  }
    return attribute;
}

@end
