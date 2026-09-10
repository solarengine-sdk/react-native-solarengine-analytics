require "json"
require "rubygems"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# 定义全局变量
isMainlandChain = false

# 根据条件设置 podname
solar_engine_pod_name = "SolarEngineSDK"
minimum_ios_sdk_version = Gem::Version.new('1.3.3')

ENV['SOLARENGINE_IOS_SDK_VERSION'] ||= ''

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
  ENV['SOLARENGINE_IOS_SDK_VERSION'] = ios_sdk_version
else
  puts "SolarEngine iOS sdk specialized config file not found"
end

puts "SolarEngine iOS sdk version: #{ENV['SOLARENGINE_IOS_SDK_VERSION']}"

if ENV['SOLARENGINE_IOS_SDK_VERSION'] && !ENV['SOLARENGINE_IOS_SDK_VERSION'].strip.empty? &&
   Gem::Version.new(ENV['SOLARENGINE_IOS_SDK_VERSION']) < minimum_ios_sdk_version
  raise "SolarEngine iOS SDK version #{ENV['SOLARENGINE_IOS_SDK_VERSION']} is too old; separated attribution requires >= 1.3.3"
end

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

  configured_ios_sdk_version = ENV['SOLARENGINE_IOS_SDK_VERSION'].to_s.strip
  ios_sdk_dependency_version = minimum_ios_sdk_version

  if !configured_ios_sdk_version.empty?
    ios_sdk_dependency_version = Gem::Version.new(configured_ios_sdk_version)
    puts "SolarEngine iOS sdk version: #{configured_ios_sdk_version}"
  else
    puts "SolarEngine iOS SDK: using version >= #{minimum_ios_sdk_version}"
  end

  s.dependency solar_engine_pod_name, ">= #{ios_sdk_dependency_version}"

  if defined?(install_modules_dependencies)
    install_modules_dependencies(s)
  else
    puts "[warn] install_modules_dependencies is not defined during pod lint"
  end

end
