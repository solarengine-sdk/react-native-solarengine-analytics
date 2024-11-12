import { Platform } from 'react-native';

export function assert(condition: boolean, message: string) {
    if (!condition) {
      throw new Error(message);
    }
  }

export function log(str:string){
    let platform = "unknown";
    if (Platform.OS === 'ios') {
        platform = "iOS";
      } else if (Platform.OS === 'android') {
        platform = "Android";
      }
    console.log("[SolarEngine ReactNative " + platform + "]: " + str);
}

/*
//obsolete:  rn does not support pass map  to native
export function safeMapSet(map:Map<string|object,string|number|boolean|JSON|object|null>
    ,key:string,value:string|number|boolean|JSON|object|null){

    if (map == null) return;
    if (value == null) return;
    if (key == null) return;
    if (value == undefined) return;
    map.set(key,value);
}
*/