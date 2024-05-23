# Release Notes

## v4.31.0 - May 22, 2024

- Feature - add support for `pubImpId` ODB param.
- Internal - "display ads" support with widget-settings enable\disable

## v4.30.0 - May 12, 2024

- Other - add code sign with Outbrain account private key to XCFramework
- Other - add privacy manifest file ([see details](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files))
- New impl in JS code starting v4.30.0 for widget height calculation.

## v4.29.0 - October 19, 2023

- Other - Support for [Apple Privacy Manifest](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files) file.


## v4.28.0 - September 14, 2023

- Feature - `sfWidget.toggleDarkMode(true/false)`` - instead of re-creating SFWidget.

## v4.27.1 - September 5, 2023

- Remove debug symbols from xcframework build.
## v4.27.0 - September 4, 2023

- Bug fix - *display ads* support caused un-wanted navigation due to wrong click detection in iFrame (we basically reverted PR#233).

## v4.26.0 - August 22, 2023

- Feature - Bridge, add support for `extid` and `extid2` for the Bridge
- Internal - Change CI release build to run dynamic_framework_build.sh directly and without SymbolsMap.
## v4.21.0 - June 28, 2023

- Feature - support Viewability and loadMore() for Bridge SwiftUI implemenation. 
- Feature - add support for "display ads" click (inside an iFrame)


## v4.20.1 - June 5, 2023

- Feature - Bridge support users who enable "large text size" in the device settings, i.e. accessibility feature. Therefore, if we detect that "large text" is on - we pass a new parameter "textSize" to the Bridge, which handles it accordingly.

## v4.19.0 - January 19, 2023
- Internal - add query param to all ODB and MV requests `ref=https://app-sdk.outbrain.com/`

## v4.18.0 - January 11, 2023
- Internal - add query param to all ODB and MV requests `ref=app.sdk`
## v4.17.0 - December 20, 2022

- Internal - use `bridgeParams` to pass values between 2 Bridge widget on the same page (instead of `t` param)
- Feature - add support for platforms API in the SDK Bridge


## v4.15.0 - October 31, 2022

- Internal - add `deviceType` and `dosv` params to Bridge and ODB requests to improve user-agent detection.

## v4.14.0 - September 14, 2022

- Feature - Bridge support for "widget external events", passed via `SFWidgetDelegate` optional method.


## v4.12.0 - August 24, 2022

- Project - add a new target to OutbrainDemo.xcodeproj - SwiftUI-Bridge sample app
- Minor - add a new delegate method to SFWidget called `widgetRendered(_ articleUrl: String, widgetId: String, widgetIndex: Int)` - to notify clients on this event


## v4.10.0 - July 14, 2022

- Minor - add a new method `reportPageViewOnTheSameWidget()` for specific publisher.
- Minor - SFWidget `loadMore()` method should be public.
- Internal - add "oo" (opted out) param to widget Viewablity URL reporting.
- Internal - add new `errorMsg` post message method to the Bridge for errors coming from the HTML

## v4.9.1 - May 30, 2022

- Internal - fix wrong param value for `url` for error reporting
- Internal - change the logic of `isPaid()` to be similar to the JS widget
- Bug fix - add 50.0 padding at the end of the WebView to fix *last rec is cut* error
- Improvement - SDK Bridge will take IDFA is available and app developer didnt pass it through


## v4.9.0 - May 11, 2022
- Bug fix - fix crash when "pos" field is missing (AB test)
- Bug fix - if skNetworkVersion is 1.0 - the variable sourceAppId can be nil
- Bug fix - add check for cell type before calling `configureSingleTableViewCell:atIndexPath:` (PR https://github.com/outbrain/OBSDKiOS/pull/206)
- Improvement - add @try\@catch wrappers around main SDK flows (classic, Smartfeed and Bridge)
- Improvement - add error reporting to Outbrain in case of SDK un-expected errors.
- Improvement - add new iPhone models to "dm" field.


## v4.8.3 - April 7, 2022
- Feature - Bridge viewability

## v4.8.2 - March 2, 2022

- Bug fix - Avoid crashing the app when check if SKAdNetworks configured correctly
- Bug fix - Bridge WebView should be transparent
- Feature - Swift Package Manager support

## v4.8.1 - December 15, 2021

- Bug fix - Smartfeed TableView horizontal cell missing outlet for `titleLabel`


## v4.8.0 - December 12, 2021

- Feature - support for `darkMode` in SFWidget (SDK-bridge).
- Infra - Migrate CircleCI to Xcode 13.1.0

## v4.7.1 - October 27, 2021

- Feature - SDK Bridge - support "t" param and idx param in the SDK bridge (2 widgets on the same page).
- Improvement - add support for darkMode param for ODB (only for Smartfeed)
- Improvement - SDK Bridge - add GDPR and CCPA params
- Improvement - `webview` property in SFWidget should be public
- Improvement - new Smartfeed logo (new design)
- Improvement - support "t" param between SDK regular widget and SDK bridge.


## v4.6.4 - October 3, 2021

- Fix - add support for ATS for SFWebView sample app
- Feature - support video on SFWebView (sdk-bridge) solution.
- Fix - add protection code to try to avoid crash in `SFViewabilityService` reported by Nine app


## v4.6.3 - August 23, 2021

- UI Fix - fix UI design for Carousel item cell - remove border and fix text alignment.

- Bug fix - very rare case, SFViewabilityService crashed on removeObjectsForKeys if "keys" are nil before completion block begin.

## v4.6.2 - August 16, 2021

- Following [request from a publisher](https://github.com/outbrain/outbrain-iOS-Framework/issues/4) - We added a new optional method to `SmartFeedDelegate` called: `-(BOOL) reloadItemsOnOrientationChanged;`


## v4.6.1 - August 16, 2021

- Following request from publisher - add support to manually set user id value via `+ (void) setUserId:(NSString * _Nullable)userId;`


## v4.6.0 - July 29, 2021

- SFWebView - SDK now contains solution for "Smartfeed on WKWebView" - see https://developer.outbrain.com/ios-sfwidget-guideline/
- Improvement - Smartfeed default UI has changes significantly - now it is similar to Outbrain latest version on Mobile Web.
- Improvement - support for Viewablity per listing for regular widget.
- Internal - adjust current implementation for "widget viewability" in Smartfeed according to new VPL impl.
- Bug fix - ODB param `api_user_id` was sent with null value.
- Internal - verify that `minimumLineSpacing` is implemented correctly by the publisher code


## v4.5.1 - June 7, 2021

- Fix - custom UI for header didn't work as expected (SDK override the font size and color).
- Internal - CircleCI finally supports Xcode 12.5.0


## v4.5.0 - May 5, 2021

- Infra - build SDK with Xcode 12.5 (iOS 14.5)
- Fix - name conflict fix SFGradientView --> SMFradientView

## v4.4.0 - April 29, 2021

- Feature - support for "Platform Endpoint"
- UI Fix - "sponsor label" position and color.
- Internal - Migrate CI artifcat hosting from Bintray to GCP.


## v4.3.0 - March 18, 2021

- Feature - add support for a new setting `dynamic:HeaderFontSize` from ODB response.
- Bug fix - add support for dark-mode for app install card
- Bug fix - widget header should appear once per widget for grid types as well.
- Bug fix - in tableview the source sometimes disappeared with layout constraints issue
- Improvement - titleColor should be the same for both organic and paid rec


## v4.2.1 - March 3, 2021

- Bug Fix - new method `openAppInstallRec:inViewController:` together with implementing `SKStoreProductViewControllerDelegate` internally to solve some cases in which `SKStoreProductViewController` didn't close correctly.

## v4.2.0 - February 25, 2021

- Important - Migrating from Xcode dynamic framework to XCFramework - [see Apple details here](https://developer.apple.com/videos/play/wwdc2019/416/)
- Internal - parse and use ODB settings `dynamic:IsShowButton` from odb response
- Internal - implement support for new ODB settings `dynamic:OrganicSourceFormat` and `dynamic:PaidSourceFormat`
- Bug fix - Walla crash on iOS12 devices
- Bug fix - Widget header should appear only once per widget


## v4.1.0 - February 22, 2021

- Feature: "Read More" ([see instructions here](https://developer.outbrain.com/ios-smartfeed-read-more-button/))
- Feauture: CTA button on paid rec
- Bug fix - Viewability on shown, fix rare crash if "req_id" is null
- Bug fix - smartfeed header for RTL in dark mode didnt change color
- UI fixes - Smartfeed on tablet (iPad) looks much better (font size, image ratio, etc)
- Dev - add a new flag to simulate app install rec `Outbrain.testAppInstall(true)`

## v4.0.1 - October 29, 2020

- Bug fix - Smartfeed via UITableView on iPad crashed on orientation change after view controller was removed from screen.

## v4.0.0 - October 19, 2020

- Feature: Weekly Highlights card
- Feature: iOS14 SKAdNetwork app install validation support.
- Feature: support for GIF images in Smartfeed.
- Internal: Built with Xcode 12.0.1, iOS14 SDK
- Internal: SDK and sample apps use `ATTrackingManager` for IDFA logic (instead of deprecated `[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]`)


## v3.9.2 - July 26, 2020

- Feature: support for GIF images in Smartfeed.
- Bug fix - Custom UI was overriden because of sdk optimization params.


## v3.9.2 - June 22, 2020

- Feature: Branded Carousel card
- Feature: App install card
- Bug fix: if "custom ui" is configured - font should stay "as is" (bypass optimizations)
- Internal: add `sdkVersion` param to video url


## v3.9.0 - May 12, 2020

- Feature: support for optimizations (A\B tests) in Smartfeed


## v3.8.7 - April 28, 2020

- Internal: `cnstv2` was sent in odb all the time because of wrong default value

## v3.8.6 - April 20, 2020

- Feature: Darkmode support (configure with `self.smartFeedManager.darkMode = true`)
- Feature: [GDPR v2 support](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md)
- Bug fix - for apps that support RTL locale, use the default xib and let ios auto-layout RTL support work.
- Improvement: Fade-in animation when loading an image in Smartfeed.
- Improvement: RTL now checks for arabic, farsi and hebrew languages.
- Internal: SDK is built with Xcode 11.3.1 on CircleCI
- Internal: Add defualt value for vidget url

## v3.8.5 - January 22, 2020

- Feature: support CCPA according to [the official iAB guidelines](https://iabtechlab.com/wp-content/uploads/2019/10/CCPA_Compliance_Framework_US_Privacy_USER_SIGNAL_API_SPEC_IABTechLab_DRAFT_for_Public_Comment.pdf) (last page)
- Feature: new Smartfeed card - `trending in category`
- Internal - add `article url` to video url params


## v3.8.4 - January 6, 2020

- Improvement: potential memory leak in Viewability on regualar widget in some cases (Barstool fix)
- Improvement: rename OBImage --> OBImageInfo due to conflict with Apple OnBoarding library
- Improvement: isSkySolutionActive will now be set manually by the app developer

## v3.8.3 - October 31, 2019

- Infrastructure - update CircleCI to use Xcode 11.1
- Infrastructure - Xcode11 (iOS 13) support (clean warnings for new Xcode).
- Bug fix - Viewability per widget didn't work for StackView solution.

## v3.8.2 - September 26, 2019

- Bug fix - crash in "Sky solution" if `numberOfRowsInSection` value < total items in the feed.

## v3.8.1 - August 26, 2019

- Bug fix - When `SFTypeStripVideo` is at the parent response, header text should have been ignored and moved to the Smartfeed header.
- Bug fix - Smartfeed "source label" was showing for organic rec if "publisher logo" image was missing.
- Bug fix - Smartfeed, rec title should be gray for organic recs on all 1 col templates.

## v3.8.0 - August 19, 2019

- Feature: add `disableCellShadows` flag to SmartFeedManager
- Feature: add UIStackView implementation support, see [UIStackView Integration Guide](https://developer.outbrain.com/ios-sdk-v3-x-smartfeed-uistackview-integration-guide).
- Feature: StackView solution, added `setUseDefaultCollectionViewDelegate` to set the SDK as the default delegate for the UICollectionView.
- Improvement: Sample apps should support portrait mode only
- Improvement: Add `skipRTL` flag to improve performance (Sky optimization).
- Improvement: Smartfeed tableview will detect if "Sky Solution" is activated and if so, will act accordingly.
- Bug fix: Drop shadow on SF cells sometimes was drawn wrong.
- Bug fix: Smartfeed - on orientation change should reload the visible cells if on iPad.
- Bug fix: Mobile device on landscape should load the same cell sizes as portrait (used different width)
- Bug fix: Viewability per listing should work for UITableView as well
- Internal: Support "shake" gesture in sample app for GTO testing.
- Internal: Upgrade project to build with Xcode 10.2.1 (iOS 12.2)

## v3.7.6 - July 20, 2019

- Bug fix - `smartFeedResponseReceived:forWidgetId:` returned the parent widget id every time.
- Improvement: smartfeed in middle will fetch recs only on app developer explicit call

## v3.7.5 - July 1, 2019

- Feature: Smartfeed in the middle of the screen support (possible to have additional custom content below the SF).
- Improvement: fix all nullability warnings in xcode 10.2.1
- Improvement: Smartfeed fetchMoreRecommendations() is now public.
- Improvement: add `testLocation()` to Outbrain.h to simulate location, e.g. "us"


## v3.7.0 - June 6, 2019

- Bug fix - Viewablity report served, if url didn't include "tm" the SDK failed to report to server.
- Bug fix - Viewablity actions, if url is nil the SDK should ignore the report.
- Feature: App developer can now use `SmartFeedManager` without implementing `SFDefaultDelegate`, in which case the SDK will handle the click events.


## v3.6.0 - April 1, 2019

- Feature: New Smartfeed API (Multivac)
- Feature: Viewability per listing
- Feature: Served vs Requested
- Improvement: Sponsored label improve implementation logic for widget with mix of paid and organic recs. Make sure we remove the paid label every time we configure a new cell
- Improvement: isRTL implementation
- Improvement: Barstool suggested fix for `decodeHTMLEnocdedString` method (stop using NSDocumentTypeDocumentAttribute from background thread).
- Improvement: Video - support reload of additional videos in the same WebView
- Improvement: In `fetchMoreRecs` logic, we want to trigger the reload on the last item as well.


## v3.5.2 - February 10, 2019

- Bug fix: detecting RTL in string was implemented incorrectly.
- Bug fix: set a limit on the number of lines in rec title for Thumbnail cells.
- Add support for displaySourceOnOrganicRec in SmartFeedManager.
- `sfItem.isCustomUI` is now supported in the horizontal view as well
- `HorizontalView` will use `sfItem` instead of recs array and OBSettings directly
- Make some order in the header file imports in the SDK.
- UI fix - If rec title is RTL we will set the source text alignment to be the same, otherwise it will look weird in the UI.

## v3.5.1 - February 10, 2019

- Bug fix - Viewability for regular widgets didn't work for index > 0
- Refactor viewability code


## v3.5.0 - January 29, 2019

- Per Sky request - add "pauseVideo" method to `SmartFeedManager`
- Per Sky request - isVideoCurrentlyPlaying and isVideoEligible flag
- OBVideoWidget support in the SDK
- Smartfeed "chunk size" settings support
- ios-release.sh script update
- Remove the "Recommended by" label from the Smartfeed
- Bug fix: WKWebView for the video player should have scrolled disable
- Bug fix: default value for isVideoEligible should be YES
- UI improvement for the Smartfeed header cell

## v3.4.9 - January 10, 2019

- Support for "source format".
- Support for "audience campaign".
- Bug fix - HTML encoding characters appeared in the UI.
- Per Sky request - implement `recommendationsForIndexPath:` method.
- Per Sky request - add `configureHorizontalItem:withRec:` method to enable app developers to configure specific UI design on horizontal item.
- Per Sky request - improve the table view loading by calling `insertRowsAtIndexPaths:` instead of `reloadData`

## v3.4.8 - January 3rd, 2019

- Add `testRTB` flag to Outbrain public class to seperate the RTB simulation from the `testMode`.
- Add `SFTypeBadType` and also according to Sky request, add `-(SFItemType) sfItemTypeFor:(NSIndexPath *)indexPath;`
- Bug fix - sponsored label was displayed on Smartfeed items when it should not appear.
- Bug fix - Smartfeed in table view - single rec tappable area was wrong.
- Bug fix - when trying to set custom ui for cell type SFTypeCarouselWithTitle the SDK reverted (by mistake) to default xib file.
- Smartfeed custom UI for `SFTypeSmartfeedHeader` will work only via:
```
self.smartFeedManager.register(headerCellNib, withReuseIdentifier: "AppSFTableViewHeaderCell", for: SFTypeSmartfeedHeader)
```
- Add `cellTitleLeadingConstraint` property for Horizontal cell (table view and collection view) per Sky request.

## v3.4.7 - December 20th, 2018

- Update signature for method `self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleCell", for: SFTypeStripWithTitle)`
- Bug fix - Sponsored label was added multiple times to the UI instead of once.
- Header files of the Smartfeed cell classes are now public.
- Add new SmartFeedDelegate method - `-(CGSize) carouselItemSize`

## v3.4.6 - December 13th, 2018

- Support header for custom UI - `self.smartFeedManager.registerHeaderNib(headerCellNib, withReuseIdentifier: "AppSFTableViewHeaderCell")`
- Support transparent color for horizontal container cell - `self.smartFeedManager.setTransparentBackground(true)`
- Support set value for horizontal margin for horizontal container cell - `self.smartFeedManager.horizontalContainerMargin = 40.0`
- New `SmartFeedManager` method - `let itemType = self.smartFeedManager.sfItemType(for: indexPath)`
- New `SmartFeedDelegate` method - `func smartFeedResponseReceived(_ recommendations: [OBRecommendation], forWidgetId widgetId: String)`
- New `SmartFeedManager` method - `self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleCell", for: SFTypeStripWithTitle)`

## v3.4.5 - December 10th, 2018

- UI fix - clean yellow border when Video player is active
- Bug fix: crash in isRTL method, NSLinguisticTagger Range or index out of bounds
- Add protection in code for custom ui to make sure we will not crash due to a bad xib file
- Bug fix - edit constraints to solve a bug in iPad carousel item.
- Improvement - remove OBLabel from Smartfeed header cell



## v3.4.4 - December 6th, 2018

- UX Optimization (derieved from Sky).
    1) First reloadData() will be called for parent + children response (was called only for parent)
    2) If Smartfeed is TableView (UX performance not so good) and we are about to update UI for relatively small number of items and feedCycleLimit is set and we're not at the limit yet - let's postpone the reloadUI and loadMoreAccordingToFeedContent instead.
- 2 fixes in Smartfeed tableview logic which solve crashes for Sky demo app in which they use UIPageViewController with ArticleVC in carousel. The quick loading cause those crashes. now it is much more stable

## v3.4.3 - December 5th, 2018

- Smartfeed Paid Label support
- Smartfeed batch size = 1
- Add update_version.sh


## v3.4.2 - Novemeber 28th, 2018

- Viewability support for Smartfeed sub-widgets (children) - UICollectiovView and UITableView
- Bug fix: Tablets image size should be about 3:2 and not 3:1

## v3.4.1 - Novemeber 26th, 2018

- Sponsored Label - create the label dynamically in the UI according to ODB response
- External ID param

## v3.3.1 - Novemeber 12th, 2018

- RTL support
- Publisher logo width and height in the UI will be set according to ODB settings
- Bug fix - Smartfeed header size adjustment to tablets (iPad)
- Add important unit tests to the iOS SDK which allow us to verify all UI templates (xib files) of the Smartfeed have their Outlets ready and connected
- Bug fix: publisher logo was missing from basic single xib files

## v3.3.0 - Novemeber 1, 2018

- GDPR support
- Bug fix - custom ui didnt change color of rec title, fix for tableview
- Bug fix - custom ui didnt change color of rec title
- Bug fix - infinite feed didnt work because condition was wrong

## v3.2.0 - October 21, 2018

- Video player in Smartfeed
- Support for Smartfeed with only a parent with single recommendation (no children)
- Designating Nullability in Objective-C APIs - https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/designating_nullability_in_objective-c_apis
