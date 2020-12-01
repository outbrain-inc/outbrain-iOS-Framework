# Read More Module - Implementation Guide

This module will expose the SmartFeed "above the scroll" on the article screen by collapsing some of the article (the part below the scroll).

The idea is to hide part of the article content and expose the Smartfeed to the user as early as possible.

## How it works?

We want to expose the Smartfeed to the user as early as possible, in order to do it the SDK will collapse some of the article items and add a "Read More" button at the end of those collaped items. This way the Smartfeed will be visible to the user before she reaches the end of the article.

When the user presses on the "Read More" button, the collapsed items will expand smoothly to their original height.

See example of how this module works below:

TODO: Add a video!

## Setup The Module

### Step 1 - Choose Items To Collapse

Before you are setting up this module, you have to think about how you want your article screen to look like after implementing this module.

It is your responsibility to configure which items the article will "collapse".

### Step 2 - TableView / CollectionView Implementation

All the "collapsable" items should be located in a separate section. This section should be the last section of your article.
The SDK will hide all the items in this section.

#### Configuration For TableView

In `numberOfRowsInSection` method of your TableView, use the `numberOfRowsInCollapsableSection: collapsableItemCount:` method of the `smartFeedManager`:

```Swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  if section == self.collapsableSection {
    return self.smartFeedManager.tableView(tableView, numberOfRowsInCollapsableSection: section, collapsableItemCount: self.collapsableItemCount)
  }
}
```

`self.collapsableSection` is your collapsable section index and `self.collapsableItemCount` is the number of rows in this section.

#### Configuration For CollectionView

In `numberOfItemsInSection` method of your CollectionView, use the `numberOfItemsInCollapsableSection: collapsableItemCount:` method of the `smartFeedManager`:

```Swift
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  if section == self.collapsableSection {
    return self.smartFeedManager.collectionView(collectionView, numberOfItemsInCollapsableSection: section, collapsableItemCount: self.collapsableItemCount)
  }
}
```

`self.collapsableSection` is your collapsable section index and `self.collapsableItemCount` is the number of items in this section.

#### `numberOfSections` method

Notice that `numberOfSections` method is the placee we are updating the `smartFeedManager` with the section index of the SmartFeed.
Make sure that you are updating the `outbrainSectionIndex` with the correct index:

```Swift
func numberOfSections(in ...) -> Int {
  self.smartFeedManager.outbrainSectionIndex = 2
  return self.smartFeedManager.numberOfSectionsInCollectionView()
}
```

In this example, the section index of the SmartFeed is 2, the collapsable section index is 1 and the article visible section index is 0.

### Step 3 - Set The Module To OBSmartFeed

In order to enable this module, use OBSmartFeed method: setReadMoreModule():
```Swift
self.smartFeedManager.setReadMoreModule()
```


## Custom UI support

This module supports Custom UI, download the template XML files from here (4.0.1) (TODO - LINK).

Find the relevant `.xib` files in SFReadMoreModuleCells folder.

#### Xib configurations

Make sure that the class of the xib is `SFCollectionViewReadMoreCell`. Connect the `readMorelabel` outlet to the label.

#### Optional - Create your own class for the xib

You can create your own class for the xib and make more changes, for example:

```Swift
import UIKit
import OutbrainSDK

class AppSFCollectionViewReadMoreCell: SFCollectionViewReadMoreCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.readMoreLabel.layer.borderColor = UIColor.red.cgColor
    }
}
```

Don't forget to change the class of your xib file.

#### Set your custom Xib

In order to set your custom xib, use the `register` method of the `smartFeedManager` and set your custom xib for `SFTypeReadMoreButton` type.

For example, in order to register the xib with the identifier: `AppSFCollectionViewReadMoreCell`:

```Swift
let readMoreCellNib = UINib(nibName: "AppSFCollectionViewReadMoreCell", bundle: bundle)
        
self.smartFeedManager.register(readMoreCellNib, withReuseIdentifier: "AppSFCollectionViewReadMoreCell", for: SFTypeReadMoreButton)
```
