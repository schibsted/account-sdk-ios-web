Pod::Spec.new do |s|
  s.name             = 'AccountSDKIOSWeb'
  s.version          = '2.1.0'
  s.summary          = 'New implementation of the Schibsted account iOS SDK using the web flows via ASWebAuthenticationSession.'
  s.homepage         = 'https://schibsted.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Schibsted' => 'tbd' }
  s.source           = { :git => 'https://github.com/schibsted/account-sdk-ios-web.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.source_files = 'Sources/AccountSDKIOSWeb/**/*'
  s.dependency 'JOSESwift', '~> 2.3.0'
  s.dependency  'SwiftLogAPI', '~> 1.4.0'
end