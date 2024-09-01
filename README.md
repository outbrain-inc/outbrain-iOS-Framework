<p align="center">
  <img height="75" src="assets/outbrain-logo.jpg" />
</p>

---

## Outbrain iOS SDK Framework

About [Outbrain](https://www.outbrain.com/)

Please make sure to review [Outbrain SDK Developers Site](https://sdk.outbrain.com/docs/iOS-SDK/Getting-Started/)

<p align="center">
  <img width="275" src="assets/iphonex-smartfeed-demo-mock.jpg" />
</p>

## Compatibility and Requirements

| **Outbrain SDK**  	| **Requirements**                                     	|
|--------------------	|------------------------------------------------------	|
| Min OutbrainSDK   	| iOS 10.3 or higher                                      	|
| Build OutbrainSDK   | iOS 16.0												|
| Languages          	| Objective-C, Swift                                   	|
| Devices            	| Any iOS compatible device: iPhones, iPads, etc.      	|
| File Sizes         	| Outbrain adds about 100KB to your iOS release app. 	|
| Architectures      	| i386, x86_64, armv7, arm64                                	|


## Installation

### Add the SDK to your project

#### Using [CocoaPods](https://cocoapods.org)

1. Add `pod 'OutbrainSDK'` into your [Podfile](https://guides.cocoapods.org/syntax/podfile.html).
2. Run `pod install`.
3. Open workspace file and run the project.

#### Using [Swift Package Manager](https://swift.org/package-manager)
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding OutbrainSDK as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```
dependencies: [
    .package(url: "https://github.com/outbrain/outbrain-iOS-Framework", .upToNextMajor(from: "x.x.x"))
]
```

### Follow The Official Documentation

Follow the [SDK integration steps](https://sdk.outbrain.com/docs/iOS-SDK/Getting-Started/) on our developer site.
