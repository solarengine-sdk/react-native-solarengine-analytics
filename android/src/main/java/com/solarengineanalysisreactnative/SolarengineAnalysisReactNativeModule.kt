package com.solarengineanalysisreactnative

import android.net.Uri
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.reyun.solar.engine.DelayDeepLinkCallback
import com.reyun.solar.engine.OnAttributionListener
import com.reyun.solar.engine.SeSdkSource
import com.reyun.solar.engine.SolarEngineConfig
import com.reyun.solar.engine.SolarEngineManager
import com.reyun.solar.engine.config.RemoteConfig
import com.reyun.solar.engine.infos.PresetEventType
import com.reyun.solar.engine.infos.SEAdClickEventModel
import com.reyun.solar.engine.infos.SEAdImpEventModel
import com.reyun.solar.engine.infos.SEAppReEngagementModel
import com.reyun.solar.engine.infos.SEAttrEventModel
import com.reyun.solar.engine.infos.SEBaseFirstEventModel
import com.reyun.solar.engine.infos.SECustomEventModel
import com.reyun.solar.engine.infos.SELoginEventModel
import com.reyun.solar.engine.infos.SEOrderEventModel
import com.reyun.solar.engine.infos.SEPurchaseEventModel
import com.reyun.solar.engine.infos.SERegisterEventModel
import com.reyun.solar.engine.tracker.SEUserDeleteType
import com.reyun.solar.engine.config.CustomDomain

import org.json.JSONArray
import org.json.JSONObject
import java.lang.reflect.Method


class SolarengineAnalysisReactNativeModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android

  companion object {
    const val NAME: String = "SolarengineAnalysisReactNative"
    var isLoggingEnabled: Boolean = false
  }

  private fun log(obj: Any, method: String) {

//    if (!isLoggingEnabled){
//      return
//    }
    if (obj is String){
      var content:String = obj.toString()
      if (content.isEmpty()){
        Log.d("[SolarEngine Android Bridge]",
          "Method: $method invoked"
        )
      }else{
        Log.d("[SolarEngine Android Bridge]",
          "Method: $method invoked \nLogContent:  $content"
        )
      }

    }else{
      Log.d("[SolarEngine Android Bridge]",
        "Method: $method invoked \n Log Content:  $obj"
      )
    }
  }
  private fun error(obj: Any, method: String) {

    if (obj is String){
      var content:String = obj.toString()
      if (content.isEmpty()){
        content = "\"log content is empty\""
      }
      Log.e("[SolarEngine Android Bridge]",
        "Method: $method invoked \nLogContent:  $content"
      )
    }else{
      Log.e("[SolarEngine Android Bridge]",
        "Method: $method invoked \n Log Content:  $obj"
      )
    }
  }

  @ReactMethod
  fun setReactNativeBridgeVersion(pluginVersion: String) {
    val log = "pluginVersion: $pluginVersion"
    log(log,"setReactNativeBridgeVersion")
    val seSdkSource = SeSdkSource()
    seSdkSource.setSdkType("reactnative")
    seSdkSource.setSubLibVersion(pluginVersion)
  }

  @ReactMethod
  fun preInit(appKey: String) {

    if (appKey.isEmpty()) {
      val message = "appKey can`t be empty"
      error(message, "preInit")
      val myException = RuntimeException("Invalid Params: $message")
      throw myException
    }
    val log = "appKey: $appKey"
    log(log,"preInit")
    val context = reactApplicationContext
    SolarEngineManager.getInstance().preInit(context, appKey)
  }
  @ReactMethod
  fun registerAttribution(attribution: Callback) {

    log("","registerAttribution")
    val singleton = SolarEngineSingleton.getInstance()
    singleton.attribution = attribution
  }
  @ReactMethod
  fun registerDeeplink(deeplink: Callback) {
    log("","registerDeeplink")

    val singleton = SolarEngineSingleton.getInstance()
    singleton.deeplink = deeplink
    SolarEngineManager.getInstance().setDeepLinkCallback { code, deeplinkInfo ->

      log("code: $code","setDeepLinkCallback")
      if (SolarEngineSingleton.getInstance().deeplink != null){
        // convert to JS object
        val readableMap = Arguments.createMap()
        val readableValueMap = Arguments.createMap()

        readableValueMap.putInt("reactnative_code", code)
        if (code == 0) {
          //处理deeplink回调成功逻辑
          val innerReadableValueMap = Arguments.createMap()
          innerReadableValueMap.putString("sedpLink",deeplinkInfo.sedpLink)
          innerReadableValueMap.putString("turlId",deeplinkInfo.turlId)
          innerReadableValueMap.putString("from",deeplinkInfo.from)

          val jsonData = SolarEngineRNUtils.mapToJSONObject(deeplinkInfo.customParams)
          val reactnativeData = SolarEngineRNUtils.convertJsonToMap(jsonData)

          innerReadableValueMap.putMap("customParams",reactnativeData.copy())

          readableValueMap.putMap("reactnative_data",innerReadableValueMap.copy())
        }

        readableMap.putMap("android_object_wrapper_key", readableValueMap)

        SolarEngineSingleton.getInstance().deeplink!!.invoke(readableMap)
        SolarEngineSingleton.getInstance().deeplink = null
      }
    }
  }
  @ReactMethod
  fun registerDelayDeeplink(delayDeeplink: Callback) {
    log("","registerDelayDeeplink")

    val singleton = SolarEngineSingleton.getInstance()
    singleton.delayDeeplink = delayDeeplink

    SolarEngineManager.getInstance().setDelayDeepLinkCallback(object : DelayDeepLinkCallback {
      override fun onReceivedSuccess(result: JSONObject) {
        //回调成功
        log("result: $result","onReceivedSuccess")
        if (SolarEngineSingleton.getInstance().delayDeeplink != null){
          // convert to JS object
          val readableMap = Arguments.createMap()
          val readableValueMap = Arguments.createMap()
          readableValueMap.putInt("reactnative_code", 0)
          val reactnativeData = SolarEngineRNUtils.convertJsonToMap(result)
          readableValueMap.putMap("reactnative_data",reactnativeData.copy())

          readableMap.putMap("android_object_wrapper_key", readableValueMap)

          SolarEngineSingleton.getInstance().delayDeeplink!!.invoke(readableMap)
          SolarEngineSingleton.getInstance().delayDeeplink = null
        }
      }

      override fun onReceivedFailed(errorCode: Int) {
        //回调失败
        error("errorCode: $errorCode","onReceivedFailed")

        // convert to JS object
        val readableMap = Arguments.createMap()
        val readableValueMap = Arguments.createMap()
        readableValueMap.putInt("reactnative_code", errorCode)
        readableMap.putMap("android_object_wrapper_key", readableValueMap)
        SolarEngineSingleton.getInstance().delayDeeplink!!.invoke(readableMap)
        SolarEngineSingleton.getInstance().delayDeeplink = null

      }
    })
  }
  @ReactMethod
  fun registerInitiateComplete(initiateComplete: Callback) {
    log("","registerInitiateComplete")

    val singleton = SolarEngineSingleton.getInstance()
    singleton.initiateComplete = initiateComplete
  }
  @ReactMethod
  fun initialize(appKey: String, configMap: ReadableMap?, remoteConfigMap: ReadableMap?, customDomainMap: ReadableMap?) {

    log("appKey: $appKey","initialize")

    if (appKey.isEmpty()) {
      val message = "appKey can`t be empty"
      error(message, "initialize")
      val myException = RuntimeException("Invalid Params: $message")
      throw myException
    }
    val context = reactApplicationContext

    val seConfig = SolarEngineConfig.Builder()

    val androidConfigs = configMap?.getMap("android")

    if (androidConfigs?.hasKey("metaAppId") == true) {
      val metaAppId = androidConfigs.getString("metaAppId")
      seConfig.setFbAppID(metaAppId)
    }
    if (androidConfigs?.hasKey("enablePersonalizedAd") == true) {
      val enablePersonalizedAd = androidConfigs.getBoolean("enablePersonalizedAd")
      seConfig.adPersonalizationEnabled(enablePersonalizedAd)
    }
    if (androidConfigs?.hasKey("enableUserData") == true) {
      val enableUserData = androidConfigs.getBoolean("enableUserData")
      seConfig.adUserDataEnabled(enableUserData)
    }
/*
ts model keys:
  enable: boolean;
  receiverDomain: string;
  ruleDomain?:string;
  receiverTcpHost?:string;
  ruleTcpHost?:string;
  gatewayTcpHost?:string;
*/
    if (customDomainMap?.hasKey("enabled") == true) {

        val customDomain = CustomDomain()
        customDomain.enable = true // 开启私有化部署
        if(customDomainMap.hasKey("receiverDomain")){
            val receiverDomain = customDomainMap.getString("receiverDomain")
            customDomain.receiverDomain = receiverDomain
        }
        if(customDomainMap.hasKey("ruleDomain")){
            val ruleDomain = customDomainMap.getString("ruleDomain")
            customDomain.ruleDomain = ruleDomain
        }
        if(customDomainMap.hasKey("receiverTcpHost")){
            val receiverTcpHost = customDomainMap.getString("receiverTcpHost")
            customDomain.tcpReceiverHost = receiverTcpHost
        }
        if(customDomainMap.hasKey("ruleTcpHost")){
            val ruleTcpHost = customDomainMap.getString("ruleTcpHost")
            customDomain.tcpRuleHost = ruleTcpHost
        }
        if(customDomainMap.hasKey("gatewayTcpHost")){
            val gatewayTcpHost = customDomainMap.getString("gatewayTcpHost")
            customDomain.tcpGatewayHost = gatewayTcpHost
        }
        seConfig.withCustomDomain(customDomain)
    }

    if (remoteConfigMap?.hasKey("enabled") == true) {
      val remote = RemoteConfig()
      val enabled = remoteConfigMap.getBoolean("enabled")
      remote.enable = enabled

      var mergeType: RemoteConfig.MergeType = RemoteConfig.MergeType.WITH_CACHE
      if (remoteConfigMap.hasKey("mergeType")) {
        val type = remoteConfigMap.getInt("mergeType")
        when (type) {
          1 -> mergeType = RemoteConfig.MergeType.WITH_USER
          2 -> mergeType = RemoteConfig.MergeType.WITH_CACHE
          else -> log("mergeType is invalid", "initialize")
        }
      }
      remote.mergeType = mergeType

      val customIDProperties = remoteConfigMap.getMap("customIDProperties")
      if (customIDProperties is ReadableMap && !remoteConfigMap.isNull("customIDProperties")) {
        val jObject = SolarEngineRNUtils.convertMapToJson(customIDProperties)
        remote.customIDProperties = jObject
      } else {
        error("customIDProperties is invalid", "initialize")
      }

      val customIDEventProperties = remoteConfigMap.getMap("customIDEventProperties")
      if (customIDEventProperties is ReadableMap && !remoteConfigMap.isNull
          ("customIDEventProperties")
      ) {
        val jObject = SolarEngineRNUtils.convertMapToJson(customIDEventProperties)
        remote.customIDEventProperties = jObject
      } else {
        error("customIDEventProperties is invalid", "initialize")
      }

      val customIDUserProperties = remoteConfigMap.getMap("customIDUserProperties")
      if (customIDUserProperties is ReadableMap && !remoteConfigMap.isNull
          ("customIDUserProperties")
      ) {
        val jObject = SolarEngineRNUtils.convertMapToJson(customIDUserProperties)
        remote.customIDUserProperties = jObject
      } else {
        error("customIDUserProperties is invalid", "initialize")
      }
      seConfig.withRemoteConfig(remote)
    }

    if (configMap?.hasKey("enableLog") == true) {
      val enableLog = configMap.getBoolean("enableLog")
      if (enableLog) {
        seConfig.logEnabled()
        isLoggingEnabled = true
      }
    }

    if (configMap?.hasKey("enable2G") == true) {
      val enable2G = configMap.getBoolean("enable2G")
      seConfig.enable2GReporting(enable2G)
    }

    if (configMap?.hasKey("enableDebug") == true) {
      val enableDebug = configMap.getBoolean("enableDebug")
      seConfig.isDebugModel(enableDebug)
    }

    if (configMap?.hasKey("enableGDPR") == true) {
      val enableGDPR = configMap.getBoolean("enableGDPR")
      seConfig.isGDPRArea(enableGDPR)
    }

    if (configMap?.hasKey("enableCoppa") == true) {
      val enableCoppa = configMap.getBoolean("enableCoppa")
      seConfig.setCoppaEnabled(enableCoppa)
    }

    if (configMap?.hasKey("enableKidsApp") == true) {
      val enableKidsApp = configMap.getBoolean("enableKidsApp")
      seConfig.setKidsAppEnabled(enableKidsApp)
    }

    if (configMap?.hasKey("enableDelayDeeplink") == true) {
      val enableDelayDeeplink = configMap.getBoolean("enableDelayDeeplink")
      seConfig.enableDelayDeeplink = enableDelayDeeplink
    }

    val solarEngineConfig:SolarEngineConfig = seConfig.build()
    solarEngineConfig.setOnAttributionListener(object : OnAttributionListener {
      override fun onAttributionSuccess(attribution: JSONObject) {
        //获取归因结果成功时执行的动作
        log("attribution: $attribution","onAttributionSuccess")
        if (SolarEngineSingleton.getInstance().attribution != null){
          // convert to JS object
          val readableMap = Arguments.createMap()
          val readableValueMap = Arguments.createMap()
          readableValueMap.putInt("reactnative_code", 0)
          val reactnativeData = SolarEngineRNUtils.convertJsonToMap(attribution)
          readableValueMap.putMap("reactnative_data",reactnativeData.copy())

          readableMap.putMap("android_object_wrapper_key", readableValueMap)

          SolarEngineSingleton.getInstance().attribution!!.invoke(readableMap)
          SolarEngineSingleton.getInstance().attribution = null
        }
      }

      override fun onAttributionFail(errorCode: Int) {
        //获取归因结果失败时执行的动作
        error("errorCode: $errorCode","onAttributionFail")

        if (SolarEngineSingleton.getInstance().attribution != null){

          log("attribution callback not null","onAttributionFail")

          // convert to JS object
          val readableMap = Arguments.createMap()
          val readableValueMap = Arguments.createMap()
          readableValueMap.putInt("reactnative_code", errorCode)

          readableMap.putMap("android_object_wrapper_key", readableValueMap)

          SolarEngineSingleton.getInstance().attribution!!.invoke(readableMap)
          SolarEngineSingleton.getInstance().attribution = null
        }else{
          log("attribution callback is null","onAttributionFail")
        }
      }
    })


    SolarEngineManager.getInstance().initialize(
      context, appKey, solarEngineConfig
    ) { code ->
//0: success
      SolarEngineSingleton.getInstance().initiateComplete?.invoke(code)
      SolarEngineSingleton.getInstance().initiateComplete = null

      val log = "init code: $code"
      log(log, "OnInitializationCallback")
    }
  }
  /************** Attribution *****************/
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun retrieveAttribution() :WritableMap?{
    val attribution = SolarEngineManager.getInstance().attribution
    log("attribution: $attribution","retrieveAttribution")

    if (attribution == null){
      return null
    }
    // convert to JS object
    val readableMap = Arguments.createMap()
    val reactnativeData = SolarEngineRNUtils.convertJsonToMap(attribution)

    readableMap.putMap("android_object_wrapper_key", reactnativeData)
    return readableMap
  }
  /************** GDPR *****************/
  @ReactMethod
  fun setGDPRArea(isGDPR:Boolean){
    log("isGDPR: $isGDPR","setGDPRArea")
    SolarEngineManager.getInstance().setGDPRArea(isGDPR)
  }

  /************** DistinctId *****************/
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun fetchDistinctId() :String{
    val distinctId = SolarEngineManager.getInstance().distinctId
    log("distinctId: $distinctId","fetchDistinctId")
    return distinctId
  }
  /************** VisitorID *****************/
  @ReactMethod
  fun setVisitorID(visitorID:String){
    log("visitorID: $visitorID","setVisitorID")
    SolarEngineManager.getInstance().visitorID = visitorID
  }
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun fetchVisitor() :String{
    val visitorID = SolarEngineManager.getInstance().visitorID
    log("fetched visitorID: $visitorID","fetchVisitor")
    return visitorID
  }
  /************** AccountID *****************/
  @ReactMethod
  fun login(accountID:String){
    log("accountID: $accountID","login")
    SolarEngineManager.getInstance().login(accountID)
  }
  @ReactMethod
  fun logout(){
    log("","logout")
    SolarEngineManager.getInstance().logout();
  }
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun fetchAccount() :String{
    val accountID = SolarEngineManager.getInstance().accountID
    log("fetched accountID: $accountID","fetchAccount")
    return accountID
  }

  /************** SuperProperties *****************/
  @ReactMethod
  fun setSuperProperties(superProperties:ReadableMap){
    log("superProperties: $superProperties","setSuperProperties")
    val context = reactApplicationContext
    val jObject = SolarEngineRNUtils.convertMapToJson(superProperties)

    val keys = jObject.keys()
    while (keys.hasNext()) {
      val key = keys.next()
      val value = jObject.opt(key)
      log("key: $key , value: $value","setSuperProperties")

      when (value) {
          is Int -> {
            SolarEngineManager.getInstance().setSuperProperties(context, key, value)
          }

        is Long -> {
          SolarEngineManager.getInstance().setSuperProperties(context,key,value)
        }

        is Float -> {
          SolarEngineManager.getInstance().setSuperProperties(context,key,value)
        }

        is Double -> {
          SolarEngineManager.getInstance().setSuperProperties(context,key,value)
        }

        is Boolean -> {
          SolarEngineManager.getInstance().setSuperProperties(context,key,value)
        }

        is String -> {
          SolarEngineManager.getInstance().setSuperProperties(context,key,value)
        }

        is JSONObject -> {
          SolarEngineManager.getInstance().setSuperProperties(context, key, value)
        }

        is JSONArray -> {
          SolarEngineManager.getInstance().setSuperProperties(context, key, value)
        }

        else -> {
          log("invalid type data, key: $key","setSuperProperties")
        }
      }

    }
  }
  @ReactMethod
  fun unsetSuperProperty(key:String){
    log("key: $key","unsetSuperProperty")
    val context = reactApplicationContext
    SolarEngineManager.getInstance().unsetSuperProperty(context,key)
  }
  @ReactMethod
  fun clearSuperProperties(){
    log("","clearSuperProperties")
    val context = reactApplicationContext
    SolarEngineManager.getInstance().clearSuperProperties(context)
  }

  /************** Properties for all Preset event *****************/
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun retrievePresetProperties() :WritableMap?{
    log("","retrievePresetProperties")

    val dataResult = SolarEngineManager.getInstance().presetProperties ?: return null

    // convert to JS object
    val readableMap = Arguments.createMap()
    val reactnativeData = SolarEngineRNUtils.convertJsonToMap(dataResult)
    readableMap.putMap("android_object_wrapper_key", reactnativeData)
    return readableMap
  }
  /************** Properties for specified Preset event *****************/
  @ReactMethod
  fun setPresetProperties(eventType:Int,properties:ReadableMap){
    log("properties: $properties","setPresetProperties")
    var appInstall = false
    var appStart = false
    var appEnd = false
    if ((eventType and 1) == 1) appInstall = true
    if ((eventType and 2) == 2) appStart = true
    if ((eventType and 4) == 4) appEnd = true

    val jObject = SolarEngineRNUtils.convertMapToJson(properties)

    if (appInstall && appStart && appEnd){
      SolarEngineManager.getInstance().setPresetEventProperties(PresetEventType.All,
        jObject)
      return
    }
    if (appInstall){
      SolarEngineManager.getInstance().setPresetEventProperties(PresetEventType.AppInstall,jObject)
    }
    if (appStart){
      SolarEngineManager.getInstance().setPresetEventProperties(PresetEventType.AppStart,jObject)
    }
    if (appEnd){
      SolarEngineManager.getInstance().setPresetEventProperties(PresetEventType.AppEnd,jObject)
    }
  }

  /************** Predefined Events *****************/
  @ReactMethod
  fun trackAdImpressionWithAttributes(adImpressionEventAttribute:ReadableMap){
    log("adImpressionEventAttribute: $adImpressionEventAttribute","trackAdImpressionWithAttributes")

    val attribute:SEAdImpEventModel = SolarEngineEventAttribute.adImpressionEventAttribute(adImpressionEventAttribute)
    SolarEngineManager.getInstance().trackAdImpression(attribute)
  }
  @ReactMethod
  fun trackAdClickWithAttributes(adClickEventAttribute:ReadableMap){
    log("adClickEventAttribute: $adClickEventAttribute","trackAdClickWithAttributes")
    val attribute: SEAdClickEventModel = SolarEngineEventAttribute.adClickEventAttribute(adClickEventAttribute)
    SolarEngineManager.getInstance().trackAdClick(attribute)
  }
  @ReactMethod
  fun trackIAPWithAttributes(iapEventAttribute:ReadableMap){
    log("iapEventAttribute: $iapEventAttribute","trackIAPWithAttributes")
    val attribute: SEPurchaseEventModel = SolarEngineEventAttribute.iapEventAttribute(iapEventAttribute)
    SolarEngineManager.getInstance().trackPurchase(attribute)
  }
  @ReactMethod
  fun trackAppAttrWithAttributes(appAttrEventAttribute:ReadableMap){
    log("appAttrEventAttribute: $appAttrEventAttribute","trackAppAttrWithAttributes")
    val attribute: SEAttrEventModel = SolarEngineEventAttribute.appAttrEventAttribute(appAttrEventAttribute)
    SolarEngineManager.getInstance().trackAttr(attribute)
  }
  @ReactMethod
  fun trackOrderWithAttributes(orderEventAttribute:ReadableMap){
    log("orderEventAttribute: $orderEventAttribute","trackOrderWithAttributes")
    val attribute: SEOrderEventModel = SolarEngineEventAttribute.orderEventAttribute(orderEventAttribute)
    SolarEngineManager.getInstance().trackOrder(attribute)
  }
  @ReactMethod
  fun trackRegisterWithAttributes(registerEventAttribute:ReadableMap){
    log("registerEventAttribute: $registerEventAttribute","trackRegisterWithAttributes")
    val attribute: SERegisterEventModel = SolarEngineEventAttribute.registerEventAttribute(registerEventAttribute)
    SolarEngineManager.getInstance().trackAppRegister(attribute)
  }
  @ReactMethod
  fun trackLoginWithAttributes(loginEventAttribute:ReadableMap){
    log("loginEventAttribute: $loginEventAttribute","trackLoginWithAttributes")
    val attribute: SELoginEventModel = SolarEngineEventAttribute.loginEventAttribute(loginEventAttribute)
    SolarEngineManager.getInstance().trackAppLogin(attribute)
  }
  /************** Custom Event *****************/
  @ReactMethod
  fun trackCustomEvent(eventName:String,customProperties:ReadableMap?, preProperties:ReadableMap?){
    log("eventName: $eventName","trackCustomEvent")

    val attribute = SECustomEventModel()
    attribute.customEventName = eventName
    if (customProperties != null) {
      val jObject = SolarEngineRNUtils.convertMapToJson(customProperties)
      attribute.customProperties = jObject
    }
    if (preProperties != null) {
      val jObject = SolarEngineRNUtils.convertMapToJson(preProperties)
      attribute.preEventData = jObject
    }

    SolarEngineManager.getInstance().track(attribute)
  }

  /************** Duration Event *****************/
  @ReactMethod
  fun eventStart(eventName:String){
    log("eventName: $eventName","eventStart")
    SolarEngineManager.getInstance().eventStart(eventName)
  }
  @ReactMethod
  fun eventEnd(eventName:String,properties:ReadableMap){
    log("properties: $properties","eventEnd")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)
    SolarEngineManager.getInstance().eventFinish(eventName,jObject)
  }
  /************** First-Time Event *****************/
  @ReactMethod
  fun trackFirstEvent(firstCheckId:String,eventAttribute:ReadableMap){
    log("eventAttribute: $eventAttribute","trackFirstEvent")

    val sdkInnerType = eventAttribute.getString("sdk_inner_type")
    var attribute: SEBaseFirstEventModel? = null
    sdkInnerType?.let {
      attribute = when (it) {

        "Custom" -> SolarEngineFirstEvent.customEventAttribute(eventAttribute)
        "AdImpression" -> SolarEngineFirstEvent.adImpressionEventAttribute(eventAttribute)
        "AdClick" -> SolarEngineFirstEvent.adClickEventAttribute(eventAttribute)
        "IAP" -> SolarEngineFirstEvent.iapEventAttribute(eventAttribute)
        "AppAttr" -> SolarEngineFirstEvent.appAttrEventAttribute(eventAttribute)
        "Order" -> SolarEngineFirstEvent.orderEventAttribute(eventAttribute)
        "Register" -> SolarEngineFirstEvent.registerEventAttribute(eventAttribute)
        "Login" -> SolarEngineFirstEvent.loginEventAttribute(eventAttribute)
        else -> {
              val message = "eventAttribute invalid"
              throw IllegalArgumentException(message)
        }
      }
    }
    attribute?.checkId = firstCheckId
    SolarEngineManager.getInstance().trackFirstEvent(attribute)
  }
  /************** Set User Property *****************/
  @ReactMethod
  fun userPropertiesInit(properties:ReadableMap){
    log("properties: $properties","userPropertiesInit")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)
    SolarEngineManager.getInstance().userInit(jObject)
  }
  @ReactMethod
  fun userPropertiesUpdate(properties:ReadableMap){
    log("properties: $properties","userPropertiesUpdate")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)
    SolarEngineManager.getInstance().userUpdate(jObject)
  }
  @ReactMethod
  fun userPropertiesAdd(properties:ReadableMap){
    log("properties: $properties","userPropertiesAdd")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)
    SolarEngineManager.getInstance().userAdd(jObject)
  }
  @ReactMethod
  fun userPropertiesUnset(properties: ReadableArray){
    log("properties: $properties ,  type is: ${properties::class}","userPropertiesUnset")

    val keys = SolarEngineRNUtils.readableArrayToStringArray(properties)
    SolarEngineManager.getInstance().userUnset(*keys)
  }
  @ReactMethod
  fun userPropertiesAppend(properties:ReadableMap){
    log("properties: $properties","userPropertiesAppend")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)
    SolarEngineManager.getInstance().userAppend(jObject)
  }
  @ReactMethod
  fun userPropertiesDelete(deleteType:Int){
    log("deleteType: $deleteType","userPropertiesDelete")
    var type = SEUserDeleteType.DELETE_BY_ACCOUNTID
    if (deleteType == 1){
      type = SEUserDeleteType.DELETE_BY_ACCOUNTID
    }else if (deleteType == 2){
      type = SEUserDeleteType.DELETE_BY_VISITORID
    }
    SolarEngineManager.getInstance().userDelete(type)
  }
  /************** Report Event Immediately *****************/
  @ReactMethod
  fun reportEventimmediately(){
    log("","reportEventimmediately")
    SolarEngineManager.getInstance().reportEventImmediately()
  }
  /************** Deep Linking *****************/
  @ReactMethod
  fun trackAppReEngagement(customProperties:ReadableMap){
    log("customProperties: $customProperties","trackAppReEngagement")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(customProperties)
    val model = SEAppReEngagementModel()
    model.setCustomProperties(jObject)
    SolarEngineManager.getInstance().trackAppReEngagement(model)
  }

  @ReactMethod
  fun appDeeplinkOpenURL(urlString:String){
    log("urlString: $urlString","appDeeplinkOpenURL")
    val uri = Uri.parse(urlString)
    SolarEngineManager.getInstance().appDeeplinkOpenURI(uri)
  }

  @ReactMethod
  fun setOaid(oaid:String){
    log("oaid: $oaid","setOaid")
    try {
      val getOaidManagerClass = Class.forName("com.reyun.plugin.oaid.GetOaidManager")
      val getInstanceMethod = getOaidManagerClass.getMethod("getInstance")
      val instance = getInstanceMethod.invoke(null)
      val setOaidMethod = instance.javaClass.getMethod("setOaid", String::class.java)
      setOaidMethod.invoke(instance, oaid)
    } catch (e: Exception) {
      error("GetOaidManager SDK not exist, please set the sdk file correctly",
        "setOaid")
      e.printStackTrace()
    }
  }
  @ReactMethod
  fun setGaid(gaid:String){
    log("gaid: $gaid","setGaid")
    SolarEngineManager.getInstance().setGaid(gaid)
  }
  @ReactMethod
  fun setChannel(channel:String){
    log("channel: $channel","setChannel")
    SolarEngineManager.getInstance().setChannel(channel)
  }

  /************** RemoteConfig *****************/

  @ReactMethod
  fun setDefaultConfig(configs:ReadableArray){
    log("configs: $configs","setDefaultConfig")
    val jsonArray = SolarEngineRNUtils.convertArrayToJson(configs)
    log("jsonArray: $jsonArray","setDefaultConfig")

    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){
      try {
        val remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager")

        log("The type of remoteConfigManagerClass is ${remoteConfigManagerClass::class}","setDefaultConfig")

        val getInstanceMethod: Method = remoteConfigManagerClass.getMethod("getInstance")
        val remoteConfigManagerInstance = getInstanceMethod.invoke(null)
        val setRemoteDefaultConfigMethod: Method =
          remoteConfigManagerClass.getMethod("setRemoteDefaultConfig", JSONArray::class.java)
        setRemoteDefaultConfigMethod.invoke(remoteConfigManagerInstance, jsonArray)
      } catch (e: Exception) {
        error("RemoteConfig SDK not exist, please set the sdk file correctly","setDefaultConfig")
        e.printStackTrace()
      }
    }else{
      error("You had disable the RemoteConfig","setDefaultConfig")
    }

  }
  @ReactMethod
  fun setRemoteConfigEventProperties(properties:ReadableMap){
    log("properties: $properties","setRemoteConfigEventProperties")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)

    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){
      try {
        val remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager")
        val getInstanceMethod: Method = remoteConfigManagerClass.getMethod("getInstance")
        val remoteConfigManagerInstance = getInstanceMethod.invoke(null)
        val setRemoteConfigEventPropertiesMethod: Method =
          remoteConfigManagerClass.getMethod("setRemoteConfigEventProperties", JSONObject::class.java)
        setRemoteConfigEventPropertiesMethod.invoke(remoteConfigManagerInstance, jObject)
      } catch (e: Exception) {
        error("RemoteConfig SDK not exist, please set the sdk file correctly",
          "setRemoteConfigEventProperties")
        e.printStackTrace()
      }
    }else{
      error("You had disable the RemoteConfig, please set the sdk file correctly",
        "setRemoteConfigEventProperties")
    }
  }
  @ReactMethod
  fun setRemoteConfigUserProperties(properties:ReadableMap){
    log("properties: $properties","setRemoteConfigUserProperties")
    val jObject: JSONObject? = SolarEngineRNUtils.convertMapToJson(properties)

    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){
      try {
        val remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager")
        val getInstanceMethod: Method = remoteConfigManagerClass.getMethod("getInstance")
        val remoteConfigManagerInstance = getInstanceMethod.invoke(null)
        val setRemoteConfigUserPropertiesMethod: Method =
          remoteConfigManagerClass.getMethod("setRemoteConfigUserProperties", JSONObject::class.java)
        setRemoteConfigUserPropertiesMethod.invoke(remoteConfigManagerInstance, jObject)
      } catch (e: Exception) {
        error("RemoteConfig SDK not exist, please set the sdk file correctly",
          "setRemoteConfigUserProperties")
        e.printStackTrace()
      }
    }else{
      error("You had disable the RemoteConfig","setRemoteConfigUserProperties")
    }
  }
  @ReactMethod
  fun fastFetchRemoteConfigWithKey(key:String, completion: Callback) {
    log("key: $key","fastFetchRemoteConfigWithKey")

    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){
      try {
        val remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager")
        val getInstanceMethod: Method = remoteConfigManagerClass.getMethod("getInstance")
        val remoteConfigManagerInstance = getInstanceMethod.invoke(null)
        val fastFetchRemoteConfigMethod: Method = remoteConfigManagerClass.
        getMethod("fastFetchRemoteConfig", String::class.java)
        val result = fastFetchRemoteConfigMethod.invoke(remoteConfigManagerInstance, key)
        var reactnativeData = result
        if (result is JSONObject){
          reactnativeData = SolarEngineRNUtils.convertJsonToMap(result as? JSONObject)
        }
        log("key: $key , result: $result ","fastFetchRemoteConfigWithKey")
        completion.invoke(reactnativeData)
      } catch (e: Exception) {
        e.printStackTrace()
        error("RemoteConfig SDK not exist, please set the sdk file correctly",
          "fastFetchRemoteConfigWithKey")

        completion.invoke(null)
      }
    }else{
      error("You had disable the RemoteConfig","fastFetchRemoteConfigWithKey")
      completion.invoke(null)
    }
  }
  @ReactMethod
  fun fastFetchRemoteConfig(completion: Callback) {
    log("","fastFetchRemoteConfig")

    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){
      try {
        val remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager")
        val getInstanceMethod: Method = remoteConfigManagerClass.getMethod("getInstance")
        val remoteConfigManagerInstance = getInstanceMethod.invoke(null)
        val fastFetchRemoteConfigMethod: Method = remoteConfigManagerClass.
        getMethod("fastFetchRemoteConfig")
        val result = fastFetchRemoteConfigMethod.invoke(remoteConfigManagerInstance)
        log("will eject completion,result: $result ","fastFetchRemoteConfig")
        val reactnativeData = SolarEngineRNUtils.convertJsonToMap(result as? JSONObject)
        completion.invoke(reactnativeData)
      } catch (e: Exception) {
        e.printStackTrace()
        error("RemoteConfig SDK not exist, please set the sdk file correctly",
          "fastFetchRemoteConfig")
        completion.invoke(null)
      }
    }else{
      error("You had disable the RemoteConfig","fastFetchRemoteConfig")
      completion.invoke(null)
    }

  }
  interface OnRemoteConfigReceivedData {
    fun onResult(result: Any?)
  }
  interface KotlinOnRemoteConfigReceivedData {
    fun onResult(result: Any?)
  }
  @ReactMethod
  fun asyncFetchRemoteConfigWithKey(key:String, completion: Callback) {
    log("key: $key","asyncFetchRemoteConfigWithKey")
    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable){

      SolarEngineRemoteConfig.asyncFetchRemoteConfigWithKey(key,object :com.solarengineanalysisreactnative.OnRemoteConfigReceivedData{
        override fun onResult(result: Any) {
          // 处理结果
          log("result: $result ,  type is: ${result::class}","asyncFetchRemoteConfigWithKey")
          if (result is JSONObject){
            val reactnativeData = SolarEngineRNUtils.convertJsonToMap(result as? JSONObject)
            completion.invoke(reactnativeData)
          }else{
            completion.invoke(result)
          }
        }
      })

    }else{
      error("You had disable the RemoteConfig","asyncFetchRemoteConfigWithKey")
      completion.invoke(null)
    }
  }


  @ReactMethod
  fun asyncFetchRemoteConfig(completion: Callback) {
    log("", "asyncFetchRemoteConfig")
    val enable = SolarEngineSingleton.getInstance().enableRemoteConfig()
    if (enable) {
      SolarEngineRemoteConfig.asyncFetchRemoteConfig(object : com.solarengineanalysisreactnative
      .OnRemoteConfigReceivedGenericsData<JSONObject> {
        override fun onResult(result: JSONObject) {
          val reactnativeData = SolarEngineRNUtils.convertJsonToMap(result as? JSONObject)
          completion.invoke(reactnativeData)
        }
      })
    }else{
      error("You had disable the RemoteConfig","asyncFetchRemoteConfig")
      completion.invoke(null)
    }

  }


}
