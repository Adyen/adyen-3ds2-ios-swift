version = '3.0.0'

Pod::Spec.new do |spec|
  spec.name                   = 'Adyen3DS2_Swift'
  spec.version                = version
  spec.license                = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  spec.homepage               = 'https://adyen.com'
  spec.authors                = { 'Adyen' => 'support@adyen.com' }
  spec.summary                = 'Accept 3D Secure 2.0 payments via Adyen.'
  spec.source                 = { :git => 'https://github.com/robertdalmeida/adyen-3ds2-ios-swift.git', :tag => version }
  spec.vendored_frameworks    = 'XCFramework/Dynamic/Adyen3DS2_Swift.xcframework'
  spec.ios.deployment_target  = '10.0'
end
