# solarengine-analysis-react-native

SolarEngine sdk plugin for ReactNative

SolarEngine ReactNative Plugin (https://help.solar-engine.com/en/docs/Quick-Integration-yk3V)

More about SolarEngine: (https://www.solar-engine.com/en)

## Installation

```sh
npm install solarengine-analysis-react-native
//or use the plugin for China
npm install solarengine-analysis-react-native-cn

```

## Usage


```js
import SolarEngine from 'solarengine-analysis-react-native';

let appKey = ""; 
if (Platform.OS === 'ios') {
   appKey = "your_iOS_appkey";//replace with your own appkey
} else if (Platform.OS === 'android') {
   appKey = "your_Android_appkey";//replace with your own appkey
}    
SolarEngine.preInit(appKey);

```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
