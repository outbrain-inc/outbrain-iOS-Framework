# Release Notes

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

## v3.2.0 - Octover 21, 2018

- Video player in Smartfeed
- Support for Smartfeed with only a parent with single recommendation (no children)
- Designating Nullability in Objective-C APIs - https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/designating_nullability_in_objective-c_apis
