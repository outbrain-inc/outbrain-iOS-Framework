# Release Notes

## v3.5.0 - ??

- Per Sky request - add "pauseVideo" method to `SmartFeedManager`
- OBVideoWidget support in the SDK
- Smartfeed "chunk size" settings support
- ios-release.sh script update
- Per Sky request - isVideoCurrentlyPlaying and isVideoEligible flag
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
