const { program } = require('commander');
const fs = require('fs');


const defaultConfigPath = './solarengine-reactnative-config.json';
const android_gradle_properties_filepath = './node_modules/solarengine-analysis-react-native/android/gradle.properties'

program
 .command('set-config')
 .description('Set configuration for the plugin')
 .option('-s, --sdkVersion <version>', 'Set the SDK version')
 .option('-t, --platform <platform>', 'Specify the platform (e.g., ios, android)')
 .option('-d, --disableRemoteConfig', 'Disable RemoteConfig')
 .option('-e, --enableRemoteConfig', 'Enable RemoteConfig')

 .action((options) => {

    const configFilePath = defaultConfigPath;
    let config = {};
    if (fs.existsSync(configFilePath)) {
      config = JSON.parse(fs.readFileSync(configFilePath));
    } else {
      config = {
        platforms: {},
        disableRemoteConfig: false
      };
    }
    if (options.sdkVersion) {
      if (!config.platforms) {
        config.platforms = {};
      }
      if (options.platform !== undefined){
        if (!config.platforms[options.platform]) {
          config.platforms[options.platform] = {};
        }
        config.platforms[options.platform].sdkVersion = options.sdkVersion;
      }else{
        config.platforms["ios"] = {};
        config.platforms["android"] = {};
        config.platforms["ios"].sdkVersion = options.sdkVersion;
        config.platforms["android"].sdkVersion = options.sdkVersion;
      }  
    }

    let disable = false;
    if (options.disableRemoteConfig == true) {
        disable = true;
    }else if (options.disableRemoteConfig == false) {
        disable = false;
    }

    if (options.enableRemoteConfig == true) {
      disable = false;
    }else if (options.enableRemoteConfig == false) {
      disable = true;
    }

    config.disableRemoteConfig = disable;



    //Modify the Android project gradle.properties file
    let gradlePropertiesContent = fs.readFileSync(android_gradle_properties_filepath, 'utf8');

    let modify_android_sdkVersion = false;
    if (options.platform !== undefined){
      if (options.platform === "android") {
        modify_android_sdkVersion = true;
      }
    }else{
      modify_android_sdkVersion = true;
    }

    if (modify_android_sdkVersion && options.sdkVersion !== undefined) {

        const sdkVersionRegex = /SolarengineAnalysisGradleProperties_SDKVersion=(.*)/;
        if (sdkVersionRegex.test(gradlePropertiesContent)) {
            gradlePropertiesContent = gradlePropertiesContent.replace(sdkVersionRegex, `SolarengineAnalysisGradleProperties_SDKVersion=${options.sdkVersion}`);
        } else {
            gradlePropertiesContent += `\nSolarengineAnalysisGradleProperties_SDKVersion=${options.sdkVersion}`;
        }
    }

    console.log('options.disableRemoteConfig: ' + options.disableRemoteConfig);
    console.log('options.enableRemoteConfig: ' + options.enableRemoteConfig);



    const enableRemoteConfigRegex = /SolarengineAnalysisGradleProperties_EnableRemoteConfig=(.*)/;
    if (disable) {
        gradlePropertiesContent = gradlePropertiesContent.replace(enableRemoteConfigRegex, `SolarengineAnalysisGradleProperties_EnableRemoteConfig=false`);
    } else {
        gradlePropertiesContent = gradlePropertiesContent.replace(enableRemoteConfigRegex, `SolarengineAnalysisGradleProperties_EnableRemoteConfig=true`);
    }

    fs.writeFileSync(android_gradle_properties_filepath, gradlePropertiesContent);


    fs.writeFileSync(configFilePath, JSON.stringify(config, null, 2));

    console.log('Configuration completed.');
  });

program.parse(process.argv);
