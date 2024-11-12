package com.solarengineanalysisreactnative
import android.util.Log
import com.facebook.react.bridge.Callback

class SolarEngineSingleton {

  companion object {
    private var instance: SolarEngineSingleton? = null

    fun getInstance(): SolarEngineSingleton {
      if (instance == null) {
        instance = SolarEngineSingleton()
      }
      return instance!!
    }
  }

  var initiateComplete: Callback? = null
  var delayDeeplink:Callback? = null
  var deeplink:Callback? = null
  var attribution:Callback? = null

  fun enableRemoteConfig(): Boolean {
    var enable = BuildConfig.ENABLE_REMOTECONFIG
    return enable
  }
}
