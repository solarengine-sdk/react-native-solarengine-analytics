require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

# 定义全局变量
isMainlandChain = false

# 根据条件设置 podname
solar_engine_pod_name = "SolarEngineSDKiOSInter"
solar_engine_pod_name = isMainlandChain ? "SolarEngineSDK" : "SolarEngineSDKiOSInter"

ENV['RCT_NEW_ARCH_ENABLED'] ||= '0' # 默认禁用新架构
ENV['SOLARENGINE_IOS_SDK_VERSION'] ||= ''
ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] ||= 'false'

puts "RCT_NEW_ARCH_ENABLED: #{ENV['RCT_NEW_ARCH_ENABLED']}"

# config_path = File.join(__dir__, "../../solarengine-reactnative-config.json")
config_path = File.expand_path("../../solarengine-reactnative-config.json", __dir__)
if File.exist?(config_path)
  config = JSON.parse(File.read(config_path))
  ios_sdk_version = config['platforms'] && config['platforms']['ios'] && config['platforms']['ios']['sdkVersion']
  disable_remote_config = config['disableRemoteConfig']
  # ENV['SOLARENGINE_IOS_SDK_VERSION'] = ios_sdk_version || '1.2.9.1'
  ENV['SOLARENGINE_IOS_SDK_VERSION'] = ios_sdk_version
  ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] = disable_remote_config ? 'true' : 'false'
end

  
puts "SolarEngine DisableRemoteConfig value: #{ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG']}"
puts "SolarEngine iOS sdk version: #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"




Pod::Spec.new do |s|
  s.name         = "solarengine-analysis-react-native"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/solarengine-sdk/react-native-solarengine-analytics.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"

  # 判断 SOLARENGINE_IOS_SDK_VERSION 是否为空字符串
  if ENV['SOLARENGINE_IOS_SDK_VERSION'] && !ENV['SOLARENGINE_IOS_SDK_VERSION'].strip.empty?
    puts "SolarEngine iOS sdk version: #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"
    s.dependency solar_engine_pod_name, '~> ' + ENV['SOLARENGINE_IOS_SDK_VERSION']    
    if ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] != 'true'
      s.dependency  "SESDKRemoteConfig", '~> ' + ENV['SOLARENGINE_IOS_SDK_VERSION']
    end
  else
    puts "SolarEngine iOS SDK: using the latest version"
    s.dependency solar_engine_pod_name
    if ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] != 'true'
      s.dependency  "SESDKRemoteConfig"
    end
  end  

  puts "SolarEngine DisableRemoteConfig value: #{ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG']}"





  # Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
  # See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
  if respond_to?(:install_modules_dependencies, true)
    install_modules_dependencies(s)
  else
    s.dependency "React-Core"

    # Don't install the dependencies when we run `pod install` in the old architecture.
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
      }
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    end
  end
end
