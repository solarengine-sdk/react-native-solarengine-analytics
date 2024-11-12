

declare type SECustomEventAttribute = {
    eventName:string
    customProperties:Object;
    preProperties:Object;
}
declare type SEAdImpressionEventAttribute = {

    adNetworkPlatform: string;
    adType:number;
    adNetworkAppID:string;
    adNetworkPlacementID:string;
    mediationPlatform:string;
    currency:string;
    ecpm:number;
    rendered:boolean;
    customProperties:Object;
}

declare type SEAdClickEventAttribute = {

    adNetworkPlatform: string;
    adType:number;
    adNetworkPlacementID:string;
    mediationPlatform:string;
    customProperties:Object;
}

export enum SEIAPStatus {
    None        = 0,
    Success     = 1,
    Failed      = 2,
    Restored    = 3
}  

export enum PresetEventType {
    INSTALL = 1,
    START   = 2,
    END     = 4
}
export enum AdType {
    Other = 0,
    RewardedVideo = 1,
    Splash = 2,
    Interstitial = 3,
    FullscreenVideo = 4,
    Banner = 5,
    Native = 6,
    NativeVideo = 7,
    MPUBanner = 8,
    InstreamVideo = 9,
    MREC = 10
}  


export const Alipay    = "alipay";
export const Weixin    = "weixin";
export const ApplePay  = "applepay";
export const Paypal    = "paypal";

const SKAdNetworkCoarseConversionValueHigh = "High"; 
const SKAdNetworkCoarseConversionValueLow = "Low";
const SKAdNetworkCoarseConversionValueMedium = "Medium";
export enum SKAdNetworkCoarseType {
    High        = SKAdNetworkCoarseConversionValueHigh,
    Low         = SKAdNetworkCoarseConversionValueLow,
    Medium      = SKAdNetworkCoarseConversionValueMedium
}

declare type SEIAPEventAttribute = {
    productID:string;
    productName:string;
    productCount:number;
    orderId:string;
    payAmount:number;
    currency:string;
    payType:string;
    payStatus:SEIAPStatus;
    failReason:string;
    customProperties:Object;
}

declare type SEAppAttrEventAttribute = {
    adNetwork:string;
    subChannel:string;
    adAccountID:string;
    adAccountName:string;
    adCampaignID:string;
    adCampaignName:string;
    adOfferID:string;
    adOfferName:string;
    adCreativeID:string;
    adCreativeName:string;
    attributionPlatform:string;
    customProperties:Object;
}

declare type SEOrderEventAttribute = {
    orderID:string;
    payAmount:number;
    currency:string;
    payType:string;
    status:string;
    customProperties:Object;
}

declare type SERegisterEventAttribute = {
    registerType:string;
    registerStatus:string;
    customProperties:Object;
}

declare type SELoginEventAttribute = {
    loginType:string;
    loginStatus:string;
    customProperties:Object;
}



export type {
    SECustomEventAttribute,
    SEAdImpressionEventAttribute,
    SEAdClickEventAttribute,
    SEIAPEventAttribute,
    SEAppAttrEventAttribute,
    SEOrderEventAttribute,
    SERegisterEventAttribute,
    SELoginEventAttribute
}


export function decorateEventType(obj: any): object {
    
    if ('adNetworkPlatform' in obj && 'adType' in obj && 'adNetworkAppID' in obj && 'adNetworkPlacementID' in obj && 'mediationPlatform' in obj && 'currency' in obj && 'ecpm' in obj && 'rendered' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "AdImpression";
    } else if ('adNetworkPlatform' in obj && 'adType' in obj && 'adNetworkPlacementID' in obj &&'mediationPlatform' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "AdClick";
    } else if ('productID' in obj && 'productName' in obj && 'productCount' in obj && 'orderId' in obj && 'payAmount' in obj && 'currency' in obj && 'payType' in obj && 'payStatus' in obj && 'failReason' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "IAP";
    } else if ('adNetwork' in obj &&'subChannel' in obj && 'adAccountID' in obj && 'adAccountName' in obj && 'adCampaignID' in obj && 'adCampaignName' in obj && 'adOfferID' in obj && 'adOfferName' in obj && 'adCreativeID' in obj && 'adCreativeName' in obj && 'attributionPlatform' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "AppAttr";
    } else if ('orderID' in obj && 'payAmount' in obj && 'currency' in obj && 'payType' in obj &&'status' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "Order";
    } else if ('registerType' in obj &&'registerStatus' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "Register";
    } else if ('loginType' in obj && 'loginStatus' in obj && 'customProperties' in obj) {
        obj.sdk_inner_type = "Login";
    } else if ('eventName' in obj && 'customProperties' in obj && ('preProperties' in obj || 'preProperties' === undefined)) {
        obj.sdk_inner_type = "Custom";
    } else {
        // TODO: should emit error
        throw new Error('the obj is invalid');
    }
    return obj;
}