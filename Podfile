pod 'AFNetworking'
pod 'SocketRocket', '0.3.1-beta2'

target :'SignalRClientObjCTests', :exclusive => true do
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
end

# this is to work around for fixing build time error:
# can't locate file for: -licucore
# more details: https://github.com/CocoaPods/CocoaPods/issues/117
post_install do |installer|
  puts ">>>> installer.libraries :: ", installer.libraries.inspect
  default_library = installer.libraries.detect { |i| i.target_definition.name == 'Pods' }
  puts ">>>> default_library :: ", default_library.inspect
  puts ">>>> default_library.library :: ", default_library.library.inspect
  ['Debug', 'Release'].each do |env|
    config_file_path = default_library.library.xcconfig_path(env)
    puts ">>> config_file_path :: ", config_file_path
    File.open("config.tmp", "w") do |io|
      io << File.read(config_file_path).gsub(/-l\"icucore\"/, '')
    end
    FileUtils.mv("config.tmp", config_file_path)
  end
end
