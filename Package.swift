// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OutbrainSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "OutbrainSDK", targets: ["WrapperSPMTarget"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "OutbrainSDK",
            path: "OutbrainSDK.xcframework"
        ),
        .target(
            name: "WrapperSPMTarget",
            dependencies: [
                .target(name: "OutbrainSDK", condition: .when(platforms: .some([.iOS])))
            ],
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        )
    ]
)
