require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# 定义全局变量
isMainlandChain = true

# 根据条件设置 podname
solar_engine_pod_name = "SolarEngineSDKiOSInter"
solar_engine_pod_name = isMainlandChain ? "SolarEngineSDK" : "SolarEngineSDKiOSInter"

ENV['SOLARENGINE_IOS_SDK_VERSION'] ||= ''
ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] ||= 'false'

# 尝试在 SDK 目录和当前工作目录查找配置文件
possible_config_paths = [
  File.expand_path("../../solarengine-reactnative-config.json", __dir__),
  File.join(__dir__, "solarengine-reactnative-config.json"),  # SDK 目录 (workspace 模式)
  File.join(Dir.pwd, "solarengine-reactnative-config.json")   # 当前工作目录 (正常使用模式)
]

config_path = possible_config_paths.find { |path| File.exist?(path) }

# puts "Looking for config file in:"
# possible_config_paths.each { |path| puts "  - #{path}" }

if config_path
  puts "SolarEngine iOS sdk specialized config file found at: #{config_path}"
  config = JSON.parse(File.read(config_path))
  ios_sdk_version = config['platforms'] && config['platforms']['ios'] && config['platforms']['ios']['sdkVersion']
  disable_remote_config = config['disableRemoteConfig']
  ENV['SOLARENGINE_IOS_SDK_VERSION'] = ios_sdk_version
  ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] = disable_remote_config ? 'true' : 'false'
else
  puts "SolarEngine iOS sdk specialized config file not found"
end

puts "SolarEngine DisableRemoteConfig value: #{ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG']}"
puts "SolarEngine iOS sdk version: #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"

Pod::Spec.new do |s|
  s.name         = "SolarengineAnalysisReactNative"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  if defined?(min_ios_version_supported)
    s.platforms    = { :ios => min_ios_version_supported }
  else
    s.platforms    = { :ios => 11.0 }
    puts "[warn] min_ios_version_supported is not defined during pod lint"
  end  

  s.source       = { :git => "https://github.com/solarengine-sdk/react-native-solarengine-analytics.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp}"
  s.private_header_files = "ios/**/*.h"

  # 判断 SOLARENGINE_IOS_SDK_VERSION 是否为空字符串
  if ENV['SOLARENGINE_IOS_SDK_VERSION'] && !ENV['SOLARENGINE_IOS_SDK_VERSION'].strip.empty?
    puts "SolarEngine iOS sdk version: #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"
    s.dependency solar_engine_pod_name, ">= #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"    
    if ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] != 'true'
      s.dependency "SESDKRemoteConfig", ">= #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"
    end
  else
    puts "SolarEngine iOS SDK: using the latest version"
    s.dependency solar_engine_pod_name
    if ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG'] != 'true'
      s.dependency  "SESDKRemoteConfig"
    end
  end  

  puts "SolarEngine DisableRemoteConfig value: #{ENV['SOLARENGINE_DISABLE_REMOTE_CONFIG']}"

  if defined?(install_modules_dependencies)
    install_modules_dependencies(s)
  else
    puts "[warn] install_modules_dependencies is not defined during pod lint"
  end

end
