#
#  Be sure to run `pod spec lint OutbrainSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name                = "OutbrainSDK"
  s.version             = "4.1.0"
  s.summary             = "Outbrain iOS SDK for app developers"
  s.description         = "Outbrain iOS SDK for app developers, please review our guidelines at https://developer.outbrain.com/ios-sdk-developer-guide/"
  s.homepage            = "https://www.outbrain.com"
  s.license             = { :type => 'Proprietary', :text => 'Copyright 2018 Outbrain. All rights reserved.' }
  s.author              = { "Oded Regev" => "oregev@outbrain.com" }
  s.platform            = :ios, "10.3"
  s.source              = { :git => "https://github.com/outbrain/outbrain-iOS-Framework.git", :tag => "version/#{s.version}" }
  s.frameworks          = "SystemConfiguration", "AdSupport", "StoreKit"
  s.requires_arc        = true
  s.preserve_paths      = "OutbrainSDK.xcframework"
  s.vendored_frameworks = "OutbrainSDK.xcframework"
  s.exclude_files       = ""

end
