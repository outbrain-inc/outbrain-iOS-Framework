# Outbrain iOS SDK

This repo contains the Outbrain mobile SDK for the iOS platform. It is intended for iOS mobile app developers who want to integrate the Outbrain product into their code. The document describes the main Outbrain interface functions.

[Release Notes](release-notes.md)

## Getting Started

In order to start developing the SDK you need to:

1) clone the project

2) Open `Samples/OutbrainDemo/OutbrainDemo.xcodeproj` in Xcode

3) Add `SDK-sources/OutbrainSDK.xcodeproj` to 2 as a project dependecy

4) Smartfeed-Dev or Journal-dev - Xcode - Build Phases --> Target Dependecies - add OutbrainSDK target 

5) Xcode - General - Embedded Binaries - add OutbrainSDK target

## Google Cloud Uploads (GCP)

We upload this project assets to GCP, in order to do it, the SDK developer should configure the `GCP_API_KEY` env var, which should contain [the content of this json file](https://outbrain.slack.com/files/UFBR82DPS/F01T315C3ST/sdk-assets-33ff7d65d16b.json).


## App Developer Guidelines

[Outbrain SDK – Documentation & Download Links]([http://developer.outbrain.com/outbrain-sdk-v3-documentation-download-links/](https://sdk.outbrain.com/docs/iOS-SDK/Getting-Started/))

## Running the tests

Unit tests for the SDK are in `OutbrainSDKTests` target.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/outbrain/OBSDKiOS/tags). 

## License

Copyright © 2018 Outbrain inc. All rights reserved.

