Pod::Spec.new do |s|
  s.name             = 'AccountSDKIOSWeb'
  s.version          = '4.0.2'
  s.summary          = 'New implementation of the Schibsted account iOS SDK using the web flows via ASWebAuthenticationSession.'
  s.homepage         = 'https://schibsted.github.io/account-sdk-ios-web/'
  s.license          = { :type => "MIT" }
  s.author           = { 'Schibsted' => 'schibstedaccount@schibsted.com' }
  s.source           = { :git => 'https://github.com/schibsted/account-sdk-ios-web.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/AccountSDKIOSWeb/**/*.{h,m,swift}'
  s.resource_bundles = {'AccountSDKIOSWeb' => 'Sources/AccountSDKIOSWeb/Resources/**/*.{xcassets,ttf,strings}'}
  s.dependency 'JOSESwift', '~> 2.4.0'
  s.dependency 'Logging', '~> 1.4.0'
end