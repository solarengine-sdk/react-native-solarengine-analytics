package com.solarengineanalysisreactnative;
//import com.reyun.remote.config.RemoteConfigManager;
import org.jetbrains.annotations.NotNull;

import java.lang.reflect.Method;

public class SolarEngineRemoteConfig {

public static void asyncFetchRemoteConfigWithKey(String key , OnRemoteConfigReceivedData callback) {
      try {
        // 通过全限定类名加载类
        Class<?> remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager");
        // 获取单例实例的方法
        Method getInstanceMethod = remoteConfigManagerClass.getMethod("getInstance");
        Object remoteConfigManagerInstance = getInstanceMethod.invoke(null);

        Object onRemoteConfigReceivedDataInstance = java.lang.reflect.Proxy.newProxyInstance(
          SolarEngineRemoteConfig.class.getClassLoader(),
          new Class[]{Class.forName("com.reyun.remote.config.OnRemoteConfigReceivedData")},
          ((proxy, method, args1) -> {
            if (method.getName().equals("onResult")){
              if (callback != null){
                callback.onResult(args1[0]);
              }
            }
            return null;
          })
        );
        Class clsName = Class.forName("com.reyun.remote.config.OnRemoteConfigReceivedData");
        // 获取 asyncFetchRemoteConfig 方法
        Method asyncFetchRemoteConfigMethod = remoteConfigManagerClass.getMethod("asyncFetchRemoteConfig",
          String.class, clsName);
        asyncFetchRemoteConfigMethod.invoke(remoteConfigManagerInstance, key,onRemoteConfigReceivedDataInstance);

      } catch (Exception e) {
        e.printStackTrace();
      }

}
  public static void asyncFetchRemoteConfig(OnRemoteConfigReceivedGenericsData callback) {
    try {
      // 通过全限定类名加载类
      Class<?> remoteConfigManagerClass = Class.forName("com.reyun.remote.config.RemoteConfigManager");
      // 获取单例实例的方法
      Method getInstanceMethod = remoteConfigManagerClass.getMethod("getInstance");
      Object remoteConfigManagerInstance = getInstanceMethod.invoke(null);

      Object onRemoteConfigReceivedGenericsDataInstance = java.lang.reflect.Proxy.newProxyInstance(
        SolarEngineRemoteConfig.class.getClassLoader(),
        new Class[]{Class.forName("com.reyun.remote.config.OnRemoteConfigReceivedGenericsData")},
        ((proxy, method, args1) -> {
          if (method.getName().equals("onResult")){
            if (callback != null){
              callback.onResult(args1[0]);
            }
          }
          return null;
        })
      );
      Class clsName = Class.forName("com.reyun.remote.config.OnRemoteConfigReceivedGenericsData");
      // 获取 asyncFetchRemoteConfig 方法
      Method asyncFetchRemoteConfigMethod = remoteConfigManagerClass.getMethod("asyncFetchRemoteConfig", clsName);
      asyncFetchRemoteConfigMethod.invoke(remoteConfigManagerInstance,onRemoteConfigReceivedGenericsDataInstance);

    } catch (Exception e) {
      e.printStackTrace();
    }

  }


}
