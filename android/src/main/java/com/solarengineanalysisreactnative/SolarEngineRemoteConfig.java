//package com.solarengineanalysisreactnative;
//
//import android.text.TextUtils;
//import android.util.Log;
//
//import com.reyun.remote.config.RemoteConfigManager;
//
//import org.json.JSONObject;
//
//public class SolarEngineRemoteConfig {
//
//  private static final String TAG = "SolarEngineRemoteConfig";
//
//  public static void asyncFetchRemoteConfigWithKey(String key, OnRemoteConfigReceivedData callback) {
//    Log.d(TAG, "asyncFetchRemoteConfigWithKey invoked, key=" + key);
//    if (callback == null) {
//      Log.e(TAG, "asyncFetchRemoteConfigWithKey callback is null");
//      return;
//    }
//    if (TextUtils.isEmpty(key)) {
//      Log.e(TAG, "asyncFetchRemoteConfigWithKey key is empty");
//      callback.onResult("");
//      return;
//    }
//    Log.d(TAG, "dispatch asyncFetchRemoteConfigWithKey to RemoteConfigManager");
//    RemoteConfigManager.getInstance().asyncFetchRemoteConfig(
//      key,
//      value -> {
//        try {
//          String result = String.valueOf(value);
//          Log.d(TAG, "asyncFetchRemoteConfigWithKey success, key=" + key + ", result=" + result);
//          callback.onResult(result);
//        } catch (Exception e) {
//          Log.e(TAG, "asyncFetchRemoteConfigWithKey result parse failed, key=" + key, e);
//          callback.onResult("");
//        }
//      }
//    );
//  }
//
//  public static void asyncFetchRemoteConfig(OnRemoteConfigReceivedGenericsData<JSONObject> callback) {
//    Log.d(TAG, "asyncFetchRemoteConfig invoked");
//    if (callback == null) {
//      Log.e(TAG, "asyncFetchRemoteConfig callback is null");
//      return;
//    }
//    Log.d(TAG, "dispatch asyncFetchRemoteConfig(all) to RemoteConfigManager");
//    RemoteConfigManager.getInstance().asyncFetchRemoteConfig(
//      new com.reyun.remote.config.OnRemoteConfigReceivedGenericsData<JSONObject>() {
//        @Override
//        public void onResult(JSONObject jsonObject) {
//          Log.d(TAG, "asyncFetchRemoteConfig success, result=" + jsonObject);
//          callback.onResult(jsonObject);
//        }
//      }
//    );
//  }
//}
