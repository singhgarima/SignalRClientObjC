pod 'AFNetworking'
pod 'SocketRocket', '0.3.1-beta2'

target :'SignalRClientObjCTests', :exclusive => true do
  pod 'Specta', :git => 'https://github.com/specta/specta.git', :tag => 'v0.3.0.beta1'
  pod 'Expecta'
  pod 'OCMock'
end

# this is to work around for fixing build time error:
# can't locate file for: -licucore
# more details: https://github.com/CocoaPods/CocoaPods/issues/117
post_install do |installer|
  default_library = installer.libraries.detect { |i| i.target_definition.name == 'Pods' }
  ['Debug', 'Release'].each do |env|
    config_file_path = default_library.library.xcconfig_path(env)
    File.open("config.tmp", "w") do |io|
      io << File.read(config_file_path).gsub(/-l\"icucore\"/, '')
    end
    FileUtils.mv("config.tmp", config_file_path)
  end
end
