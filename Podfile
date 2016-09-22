platform :ios, '8.0'
use_frameworks!

def getcar_pods
    pod 'Alamofire', '~> 3.5'
    pod 'RxSwift', '~> 2.6.0'
    pod 'RxCocoa', '~> 2.6.0'
    pod 'RxBlocking', '~> 2.6.0'
    pod 'SwiftyJSON', '~> 2.4.0'
    pod 'Kingfisher', '~> 2.6.0'
    pod 'RongCloudIMKit'
    pod 'AMap3DMap'
    pod 'AMapSearch'
    pod 'AMapLocation'
    pod 'Bugly'
    pod 'RealmSwift', '~> 1.1.0'
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target 'GetCarSwift' do
    getcar_pods
end

target 'GetCarSwiftTests' do
    getcar_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3' # or '3.0'
    end
  end
end
