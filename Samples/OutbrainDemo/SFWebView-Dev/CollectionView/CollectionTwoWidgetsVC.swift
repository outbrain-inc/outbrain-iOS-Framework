//
//  CollectionVC.swift
//  OBSDKiOS-SFWidget
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices
import OutbrainSDK

class CollectionTwoWidgetsVC : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    let contentCellReuseIdentifier = "contentCollectionCell"
    
    var obSmartfeedWidget: SFWidget!
    var obRegularWidget: SFWidget!
    
    let originalArticleItemsCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SFWidgetCollectionCell.self, forCellWithReuseIdentifier: "SFWidgetCell")
        
        obSmartfeedWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        obRegularWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        
        self.obRegularWidget.configure(with: self, url: OBConf.baseURL, widgetId: OBConf.regularWidgetID, widgetIndex: 0, installationKey: OBConf.installationKey, userId: "F22700D5-1D49-42CC-A183-F36765261112", darkMode:true)
        
        
        self.obSmartfeedWidget.configure(with: self, url: OBConf.baseURL, widgetId: OBConf.smartFeedWidgetID, widgetIndex: 1, installationKey: OBConf.installationKey, userId: "F22700D5-1D49-42CC-A183-F36765261112", darkMode:false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        self.obSmartfeedWidget.viewWillTransition(to: size, with: coordinator)
        self.obRegularWidget.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: UICollectionView methods
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: textHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case 2,4,5:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellReuseIdentifier,
                                                      for: indexPath)
        case 3:
            if let sfWidgetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFWidgetCell", for: indexPath) as? SFWidgetCollectionCell {
                cell = sfWidgetCell
            }
            break;
        default:
            if let sfWidgetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFWidgetCell", for: indexPath) as? SFWidgetCollectionCell {
                cell = sfWidgetCell
            }
            break;
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = UIColor.white;
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = UIColor.black;
                
            }
            break
        case 2, 4, 5:
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = UIColor.white;
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = UIColor.black;
            }
            break
        case 3:
            if let sfWidgetCell = cell as? SFWidgetCollectionCell {
                obRegularWidget.willDisplay(sfWidgetCell)
            }
        default:
            if let sfWidgetCell = cell as? SFWidgetCollectionCell {
                obSmartfeedWidget.willDisplay(sfWidgetCell)
            }
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return originalArticleItemsCount + 2 // 2 widgets on this screen
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        
        switch indexPath.row {
            case 0:
                return CGSize(width: width, height: 0.5625*width)
            case 1:
                return CGSize(width: width, height: 0.35*width)
            case 2,4,5:
                return CGSize(width: width, height: 200.0)
            case 3:
                return CGSize(width: width, height: self.obRegularWidget.getCurrentHeight())
            default:
                break
        }
        return CGSize(width: width, height: self.obSmartfeedWidget.getCurrentHeight())
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        obRegularWidget.scrollViewDidScroll(scrollView)
        obSmartfeedWidget.scrollViewDidScroll(scrollView)
    }
}

// MARK: SFWidgetDelegate
extension CollectionTwoWidgetsVC: SFWidgetDelegate {
    func didChangeHeight() {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func onOrganicRecClick(_ url: URL) {
        // handle click on organic url
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func onRecClick(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func widgetEvent(_ eventName: String, additionalData: [String : Any]) {
        print("App received widgetEvent: ** \(eventName) ** with data: \(additionalData)")
    }
}
