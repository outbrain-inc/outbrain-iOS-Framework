#
#  Be sure to run `pod spec lint OutbrainSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                = "OutbrainSDK"
  s.version             = "5.3.2"
  s.summary             = "Outbrain iOS SDK for app developers"
  s.description         = "Outbrain iOS SDK for app developers, please review our guidelines at https://sdk.outbrain.com/"
  s.documentation_url   = "https://sdk.outbrain.com/"
  s.homepage            = "https://www.outbrain.com"
  s.license             = { :type => 'Proprietary', :text => 'Copyright 2024 Outbrain. All rights reserved.' }
  s.author              = { "Oded Regev" => "oregev@outbrain.com" }
  s.platform            = :ios, "14.0"
  s.source              = { :git => "https://github.com/outbrain/outbrain-iOS-Framework.git", :tag => "#{s.version}" }
  s.frameworks          = "SystemConfiguration", "AdSupport", "StoreKit"
  s.requires_arc        = true
  s.preserve_paths      = "OutbrainSDK.xcframework"
  s.vendored_frameworks = "OutbrainSDK.xcframework"
  s.exclude_files       = ""

end
