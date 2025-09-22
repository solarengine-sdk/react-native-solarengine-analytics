package com.solarengineanalysisreactnative
import com.facebook.react.bridge.ReadableMap
import com.reyun.solar.engine.infos.SEAdClickEventModel
import com.reyun.solar.engine.infos.SEAdImpEventModel
import com.reyun.solar.engine.infos.SEAttrEventModel
import com.reyun.solar.engine.infos.SELoginEventModel
import com.reyun.solar.engine.infos.SEOrderEventModel
import com.reyun.solar.engine.infos.SEPurchaseEventModel
import com.reyun.solar.engine.infos.SERegisterEventModel

class SolarEngineEventAttribute {

  companion object {


    fun adImpressionEventAttribute(eventAttribute: ReadableMap): SEAdImpEventModel {
      val attribute = SEAdImpEventModel()
      if (eventAttribute.hasKey("adNetworkPlatform")){
        attribute.adNetworkPlatform = eventAttribute.getString("adNetworkPlatform")
      }
      if (eventAttribute.hasKey("adType")){
        attribute.adType = eventAttribute.getInt("adType")
      }
      if (eventAttribute.hasKey("adNetworkAppID")){
        attribute.adNetworkAppID = eventAttribute.getString("adNetworkAppID")
      }
      if (eventAttribute.hasKey("adNetworkPlacementID")){
        attribute.adNetworkADID = eventAttribute.getString("adNetworkPlacementID")
      }
      if (eventAttribute.hasKey("mediationPlatform")){
        attribute.mediationPlatform = eventAttribute.getString("mediationPlatform")
      }

      if (eventAttribute.hasKey("currency")){
        attribute.currencyType = eventAttribute.getString("currency")
      }
      if (eventAttribute.hasKey("ecpm")){
        attribute.ecpm = eventAttribute.getDouble("ecpm")
      }
      if (eventAttribute.hasKey("rendered")){
        attribute.isRenderSuccess = eventAttribute.getBoolean("rendered")
      }

      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }

      return attribute
    }

    fun adClickEventAttribute(eventAttribute: ReadableMap): SEAdClickEventModel {
      val attribute = SEAdClickEventModel()
      if (eventAttribute.hasKey("adNetworkPlatform")){
        attribute.adPlatform = eventAttribute.getString("adNetworkPlatform")
      }
      if (eventAttribute.hasKey("adType")){
        attribute.adType = eventAttribute.getInt("adType")
      }
      if (eventAttribute.hasKey("adNetworkPlacementID")){
        attribute.adNetworkADID = eventAttribute.getString("adNetworkPlacementID")
      }
      if (eventAttribute.hasKey("mediationPlatform")){
        attribute.mediationPlatform = eventAttribute.getString("mediationPlatform")
      }
      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }
      return attribute
    }

    fun iapEventAttribute(eventAttribute: ReadableMap): SEPurchaseEventModel {
      val attribute = SEPurchaseEventModel()

      if (eventAttribute.hasKey("productID")){
        attribute.productId = eventAttribute.getString("productID")
      }
      if (eventAttribute.hasKey("productName")){
        attribute.productName = eventAttribute.getString("productName")
      }
      if (eventAttribute.hasKey("productCount")){
        attribute.productNum = eventAttribute.getInt("productCount")
      }
      if (eventAttribute.hasKey("orderId")){
        attribute.orderId = eventAttribute.getString("orderId")
      }
      if (eventAttribute.hasKey("payAmount")){
        attribute.payAmount = eventAttribute.getDouble("payAmount")
      }
      if (eventAttribute.hasKey("currency")){
        attribute.currencyType = eventAttribute.getString("currency")
      }
      if (eventAttribute.hasKey("payType")){
        val payTypeValue  = eventAttribute.getString("payType")
        var iapEventPayType: String? = null
        val wx = "Wei" + "xin"
        payTypeValue?.let { payType ->
          iapEventPayType = when (payType) {
            "Alipay" -> "alipay"
            wx -> "wei" + "xin"
            "ApplePay" -> "apple" + "pay"
            "Paypal" -> "paypal"
            else -> payType
          }
        }
        attribute.payType = iapEventPayType
      }
      if (eventAttribute.hasKey("payStatus")){
        attribute.payStatus = eventAttribute.getInt("payStatus")
      }
      if (eventAttribute.hasKey("failReason")){
        attribute.failReason = eventAttribute.getString("failReason")
      }

      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }
      return attribute
    }

    fun orderEventAttribute(eventAttribute: ReadableMap): SEOrderEventModel {
      val attribute = SEOrderEventModel()

      if (eventAttribute.hasKey("orderID")){
        attribute.orderId = eventAttribute.getString("orderID")
      }
      if (eventAttribute.hasKey("payAmount")){
        attribute.payAmount = eventAttribute.getDouble("payAmount")
      }
      if (eventAttribute.hasKey("currency")){
        attribute.currencyType = eventAttribute.getString("currency")
      }
      if (eventAttribute.hasKey("payType")){
        val payTypeValue  = eventAttribute.getString("payType")
        var iapEventPayType: String? = null
        val wx = "Wei" + "xin"
        payTypeValue?.let { payType ->
          iapEventPayType = when (payType) {
            "Alipay" -> "alipay"
            wx -> "wei" + "xin"
            "ApplePay" -> "apple" + "pay"
            "Paypal" -> "paypal"
            else -> payType
          }
        }
        attribute.payType = iapEventPayType
      }
      
      if (eventAttribute.hasKey("status")){
        attribute.status = eventAttribute.getString("status")
      }

      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }

      return attribute
    }

    fun registerEventAttribute(eventAttribute: ReadableMap): SERegisterEventModel {
      val attribute = SERegisterEventModel()
      if (eventAttribute.hasKey("registerType")){
        attribute.regType = eventAttribute.getString("registerType")
      }
      if (eventAttribute.hasKey("registerStatus")){
        attribute.status = eventAttribute.getString("registerStatus")
      }
      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }
      return attribute
    }

    fun loginEventAttribute(eventAttribute: ReadableMap): SELoginEventModel {
      val attribute = SELoginEventModel()

      if (eventAttribute.hasKey("loginType")){
        attribute.loginType = eventAttribute.getString("loginType")
      }
      if (eventAttribute.hasKey("loginStatus")){
        attribute.status = eventAttribute.getString("loginStatus")
      }
      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }
      return attribute
    }

    fun appAttrEventAttribute(eventAttribute: ReadableMap): SEAttrEventModel {
      val attribute = SEAttrEventModel()
      if (eventAttribute.hasKey("adNetwork")){
        attribute.adNetwork = eventAttribute.getString("adNetwork")
      }
      if (eventAttribute.hasKey("subChannel")){
        attribute.subChannel = eventAttribute.getString("subChannel")
      }
      if (eventAttribute.hasKey("adAccountID")){
        attribute.adAccountId = eventAttribute.getString("adAccountID")
      }
      if (eventAttribute.hasKey("adAccountName")){
        attribute.adAccountName = eventAttribute.getString("adAccountName")
      }
      if (eventAttribute.hasKey("adCampaignID")){
        attribute.adCampaignId = eventAttribute.getString("adCampaignID")
      }
      if (eventAttribute.hasKey("adCampaignName")){
        attribute.adCampaignName = eventAttribute.getString("adCampaignName")
      }
      if (eventAttribute.hasKey("adOfferID")){
        attribute.adOfferId = eventAttribute.getString("adOfferID")
      }
      if (eventAttribute.hasKey("adOfferName")){
        attribute.adOfferName = eventAttribute.getString("adOfferName")
      }
      if (eventAttribute.hasKey("adCreativeID")){
        attribute.adCreativeId = eventAttribute.getString("adCreativeID")
      }
      if (eventAttribute.hasKey("adCreativeName")){
        attribute.adCreativeName = eventAttribute.getString("adCreativeName")
      }
      if (eventAttribute.hasKey("attributionPlatform")){
        attribute.attributionPlatform = eventAttribute.getString("attributionPlatform")
      }

      if (eventAttribute.hasKey("customProperties")){
        val receivedObject: ReadableMap? = eventAttribute.getMap("customProperties")
        if (receivedObject != null) {
          val jObject = SolarEngineRNUtils.convertMapToJson(receivedObject)
          attribute.customProperties = jObject
        }
      }
      return attribute
    }


  }

}
