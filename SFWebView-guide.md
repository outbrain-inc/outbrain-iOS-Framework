# OBSDKiOS-SFWidget

## Integration guide

### In Your ViewController

Hold a global variable for the SFWidget:
```swift
var sfWidget: SFWidget!
```

Your ViewController should implement `SFWidgetDelegate`:
```swift
extension YourVC: SFWidgetDelegate {
    func didChangeHeight() {
        // See implementation for UITableView or UICollectionView (at the bottom of this section)
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

Initialize the `SFWidget` in `viewDidLoad`:
```swift
sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
sfWidget.setProperties(
    delegate: self, // SFWidgetDelegate
    url: "http://mobile-demo.outbrain.com",
    widgetId: "MB_1",
    installationKey: "NANOWDGT01"
)
```

Override method `scrollViewDidScroll`:
```swift
override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    sfWidget.scrollViewDidScroll(scrollView: scrollView)
}
```

### UITableView

#### SFWidgetDelegate

In your implementation for `SFWidgetDelegate`:
```swift
func didChangeHeight() {
  tableView.beginUpdates()
  tableView.endUpdates()
}
```


#### In viewDidLoad
Register `SFWidgetTableViewCell`:
```swift
tableView.register(SFWidgetTableViewCell.self, forCellReuseIdentifier: "SFWidgetCell")
```

#### UITableView methods

numberOfRowsInSection:
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return originalArticleItemsCount + 1
}
```

cellForRowAt indexPath:
```swift
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
```swift
sfWidget.willDisplaySFWidgetCell(cell: sfWidgetCell)
```

heightForRowAt indexPath:
```swift
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

### UICollectionView

#### SFWidgetDelegate

In your implementation for `SFWidgetDelegate`:
```swift
func didChangeHeight() {
  collectionView.performBatchUpdates(nil, completion: nil)
}
```

#### In viewDidLoad
Register `SFWidgetCollectionViewCell`:
```swift
collectionView.register(SFWidgetCollectionViewCell.self, forCellWithReuseIdentifier: "SFWidgetCell")
```

#### UICollectionView methods

numberOfItemsInSection:
```swift
override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return originalArticleItemsCount + 1
}
```

cellForItemAt indexPath, cell for last item should be:
```swift
if let sfWidgetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFWidgetCell", for: indexPath) as? SFWidgetCollectionViewCell {
  return sfWidgetCell
}
```

willDisplay cell:
```swift
if let sfWidgetCell = cell as? SFWidgetCollectionViewCell {
    sfWidget.willDisplaySFWidgetCell(cell: sfWidgetCell)
}
```

sizeForItemAt indexPath, for the last item (SFWidget):
```swift
return CGSize(width: collectionView.frame.size.width, height: self.sfWidget.getCurrentHeight())
```




### Support Orientation Changes

You should override `viewWillTransition` method.

#### For UITableView

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  super.viewWillTransition(to: size, with: coordinator)
  sfWidget.viewWillTransition(coordinator: coordinator)
}
```

#### For UICollectionView

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  super.viewWillTransition(to: size, with: coordinator)
  collectionView.collectionViewLayout.invalidateLayout()
  sfWidget.viewWillTransition(coordinator: coordinator)
}
```
