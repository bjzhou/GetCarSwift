platform :ios, '9.0'
use_frameworks!

def all_pods
    pod 'Alamofire',  '~> 4.0.1'
    pod 'RxSwift',    '~> 3.0.0-beta.1'
    pod 'RxCocoa',    '~> 3.0.0-beta.1'
    pod 'SwiftyJSON', '~> 3.1.0'
    pod 'Kingfisher', '~> 3.1.1'
    pod 'RealmSwift', '~> 2.0.1'
    pod 'R.swift.Library'
    pod 'RongCloudIMKit'
    pod 'AMap3DMap'
    pod 'AMapSearch'
    pod 'AMapLocation'
    pod 'Bugly'
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target 'GetCarSwift' do
    all_pods
end

target 'GetCarSwiftTests' do
    all_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

