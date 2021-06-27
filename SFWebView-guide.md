# SFWidget Guidelines

[Introduction](#introduction)

[Common Integration Instructions](#common)

[UITableView Integration](#tableview)

[UICollectionView Integration](#collectionview)

[UIScrollView Integration](#scrollview)

[Support Orientation Changes](#orientation)

## Introduction

SFWebView is a new solution provided by Outbrain to integrate our SmartLogic feed in a native iOS app. This solution should work in either a ScrollView, UICollectionView or UITableView. 

The general concept is to include `SFWidget` which encapsulate `WKWebView` which in turn loads the SmartLogic feed in a Web format with a native bridge to pass messages from\to native code.

## Common Integration Instructions

In Your ViewController

#### 1) Hold a global variable for the SFWidget:

```
var sfWidget: SFWidget!
```

#### 2) Your ViewController should implement `SFWidgetDelegate`:

```
extension YourVC: SFWidgetDelegate {
    func didChangeHeight() {
        // See implementation for UITableView \ UICollectionView \ UIScrollView (at the bottom of this section)
    }
    
    func onOrganicRecClick(url: URL) { // optional
        // handle click on organic recommendation
    }
    
    func onRecClick(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
```

Notice that `onOrganicRecClick` is an optional method. Use this method to handle clicks on organic recommendations (for example, navigate in your app).

#### 3) Initialize the `SFWidget` in `viewDidLoad`:

```
sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
sfWidget.setProperties(
    delegate: self, // SFWidgetDelegate
    url: "http://mobile-demo.outbrain.com",
    widgetId: "MB_1",
    installationKey: "NANOWDGT01"
)
```

#### 4) Override method `scrollViewDidScroll`:

```
override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    sfWidget.scrollViewDidScroll(scrollView: scrollView)
}
```

## <span id="tableview">UITableView</span>

#### SFWidgetDelegate

In your implementation for `SFWidgetDelegate`:

```
func didChangeHeight() {
  tableView.beginUpdates()
  tableView.endUpdates()
}
```


#### In viewDidLoad
Register `SFWidgetTableViewCell`:

```
tableView.register(SFWidgetTableViewCell.self, forCellReuseIdentifier: "SFWidgetCell")
```

#### UITableView methods

numberOfRowsInSection:

```
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return originalArticleItemsCount + 1
}
```

cellForRowAt indexPath:

```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell:UITableViewCell?

    switch indexPath.row {
    case 0:
        cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
    case 1:
        cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
    case 2,3,4:
        cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
    default:
        if let sfWidgetCell = self.tableView.dequeueReusableCell(withIdentifier: "SFWidgetCell") as? SFWidgetTableViewCell {
            cell = sfWidgetCell
        }
        break;
    }
    return cell ?? UITableViewCell()
}
```

willDisplay cell `SFWidgetTableViewCell`, call to:

```
sfWidget.willDisplaySFWidgetCell(cell: sfWidgetCell)
```

heightForRowAt indexPath:

```
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.row {
    case 0:
        return UIDevice.current.userInterfaceIdiom == .pad ? 400 : 250;
    case 1:
        return UIDevice.current.userInterfaceIdiom == .pad ? 150 : UITableView.automaticDimension;
    case 2, 3, 4:
        return UIDevice.current.userInterfaceIdiom == .pad ? 200 : UITableView.automaticDimension;
    default:
        return self.sfWidget.getCurrentHeight();
    }
}
```



## <span id="collectionview">UICollectionView </span>

#### SFWidgetDelegate

In your implementation for `SFWidgetDelegate`:

```
func didChangeHeight() {
  collectionView.performBatchUpdates(nil, completion: nil)
}
```

#### In viewDidLoad
Register `SFWidgetCollectionViewCell`:

```
collectionView.register(SFWidgetCollectionViewCell.self, forCellWithReuseIdentifier: "SFWidgetCell")
```

#### UICollectionView methods

numberOfItemsInSection:

```
override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return originalArticleItemsCount + 1
}
```

cellForItemAt indexPath, cell for last item should be:

```
if let sfWidgetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFWidgetCell", for: indexPath) as? SFWidgetCollectionViewCell {
  return sfWidgetCell
}
```

willDisplay cell:

```
if let sfWidgetCell = cell as? SFWidgetCollectionViewCell {
    sfWidget.willDisplaySFWidgetCell(cell: sfWidgetCell)
}
```

sizeForItemAt indexPath, for the last item (SFWidget):

```
return CGSize(width: collectionView.frame.size.width, height: self.sfWidget.getCurrentHeight())
```



## <span id="scrollview">UIScrollView </span>

1) Embed `SFWidget` inside a ScrollView. Make sure you create an Outlet to the SFWidget height constraints (see sample app for code example), for example:

```
@IBOutlet weak var sfWidgetHeightConstraint: NSLayoutConstraint!
```

2) In `viewDidLoad()` you should init `SFWidget` as explained in "Common Integration".


3) In your implementation for `SFWidgetDelegate`:

```
func didChangeHeight() {
  self.sfWidgetHeightConstraint.constant = self.sfWidget.getCurrentHeight()
}
```


## <span id="orientation">Support Orientation Changes</span>

You should override `viewWillTransition` method.

#### For UITableView

```
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  super.viewWillTransition(to: size, with: coordinator)
  sfWidget.viewWillTransition(coordinator: coordinator)
}
```

#### For UICollectionView

```
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  super.viewWillTransition(to: size, with: coordinator)
  collectionView.collectionViewLayout.invalidateLayout()
  sfWidget.viewWillTransition(coordinator: coordinator)
}
```

#### For UIScrollView
```
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  super.viewWillTransition(to: size, with: coordinator)
  self.sfWidget.viewWillTransition(coordinator: coordinator)
  coordinator.animate(alongsideTransition: nil) { _ in
      self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.contentView.frame.size.height)
  }
}
```
