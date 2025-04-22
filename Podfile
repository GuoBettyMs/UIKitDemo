# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'SwiftTest' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiMeta
  pod 'Alamofire', '~> 5.6.2'          #网络框架 5.6.4
  pod 'SwiftyJSON', '~> 5.0.1'         #JSON解析框架,5.0.2
  pod 'SQLite.swift', '~> 0.13.3'    #数据库框架
  pod 'SideMenu', '~> 6.0'           #侧滑栏
  pod 'NVActivityIndicatorView'      #加载指示,5.2.0
  pod 'MBProgressHUD', '~> 1.2.0'    #弹框框架
  
  pod 'RxSwift', '~> 6.5.0'
  pod 'RxCocoa', '~> 6.5.0'
  pod 'SnapKit', '~> 5.6.0'
#  pod 'AAInfographics', :git => 'https://github.com/AAChartModel/AAChartKit-Swift.git' #不可改动,不同版本功能不同
#  pod 'Bugly'
  pod 'Kingfisher'        #下载网络图像,7.12.0
  pod 'AAInfographics', '~> 6.0.0'
  
end

# 解决虚拟机兼容性问题导致无法运行
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end
    end
end
