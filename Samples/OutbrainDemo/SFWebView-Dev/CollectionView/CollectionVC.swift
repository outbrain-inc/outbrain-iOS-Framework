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

class CollectionVC : UICollectionViewController, UICollectionViewDelegateFlowLayout, OBViewController {
    
    var widgetId: String = OBConf.smartFeedWidgetID
    
    let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    let contentCellReuseIdentifier = "contentCollectionCell"
    
    var sfWidget: SFWidget!
    
    let originalArticleItemsCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SFWidgetCollectionCell.self, forCellWithReuseIdentifier: "SFWidgetCell")
        
        sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        self.sfWidget.configure(with: self, url: OBConf.baseURL, widgetId: self.widgetId, installationKey: OBConf.installationKey)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        self.sfWidget.viewWillTransition(to: size, with: coordinator)
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
        case 2,3,4:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellReuseIdentifier,
                                                      for: indexPath)
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
        case 2, 3, 4:
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = UIColor.white;
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = UIColor.black;
            }
            break
        default:
            if let sfWidgetCell = cell as? SFWidgetCollectionCell {
                sfWidget.willDisplay(sfWidgetCell)
            }
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return originalArticleItemsCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        
        switch indexPath.row {
            case 0:
                return CGSize(width: width, height: 0.5625*width)
            case 1:
                return CGSize(width: width, height: 0.35*width)
            case 2,3,4:
                return CGSize(width: width, height: 200.0)
            default:
                break
        }
        return CGSize(width: width, height: self.sfWidget.getCurrentHeight())
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget.scrollViewDidScroll(scrollView)
    }
}

// MARK: SFWidgetDelegate
extension CollectionVC: SFWidgetDelegate {
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
        print("App revceived widgetEvent: \(eventName) with data: \(additionalData)")
    }
}
