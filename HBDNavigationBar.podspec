Pod::Spec.new do |s|
  s.name                      = 'HBDNavigationBar'
  s.version                   = '1.9.6'
  s.summary                   = 'An aspiring UINavigationBar.'
  s.description               = <<-DESC
导航栏管理工具，支持OC iOS9.0及以后版本；支持Swift，目前仅支持Swift 5.0及以后版本，其他版本未经测试；
                       DESC

  s.homepage                  = 'https://github.com/listenzz/HBDNavigationBar'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'listen' => 'listenzz@163.com' }
  s.source                    = { :git => 'https://github.com/listenzz/HBDNavigationBar.git', :tag => s.version.to_s }
  s.frameworks                = 'UIKit','Foundation'
  s.ios.deployment_target     = '10.0'
  s.default_subspec           = 'Core'
  
  s.subspec 'Core' do |spec|
    spec.source_files         = 'HBDNavigationBar/Classes/**/*.{h,m}'
    spec.public_header_files  = 'HBDNavigationBar/Classes/**/*.h'
  end

  s.subspec 'Swift' do |spec|
    spec.swift_version        = '5.0'
    spec.source_files         = 'HBDNavigationBar/Classes/**/*.swift'
    spec.pod_target_xcconfig  = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS'  => 'PERMISSIONSKIT_CAMERA PERMISSIONSKIT_COCOAPODS'
    }
  end
end
