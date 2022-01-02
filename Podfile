source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

target 'terrible-sync' do
  pod 'F53OSC', :git => 'https://github.com/Figure53/F53OSC.git'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ENABLE_OBJC_WEAK'] ||= 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
