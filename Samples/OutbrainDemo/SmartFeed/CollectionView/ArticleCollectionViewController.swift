//
//  ArticleCollectionViewController.swift
//  ios-SmartFeed
//
//  Created by Gai Carmi on 2/4/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import SafariServices

import OutbrainSDK

class ArticleCollectionViewController: UICollectionViewController {
    
    let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    let contentCellReuseIdentifier = "contentCollectionCell"
    let outbrainHeaderCellReuseIdentifier = "outbrainHeaderCollectionCell"
    let outbrainRecCellReuseIdentifier = "outbrainRecCollectionCell"

    
    fileprivate let itemsPerRow: CGFloat = 1
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    let originalArticleItemsCount = 6

    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setupSmartFeed()
    }
    
    func setupSmartFeed() {
        guard let collectionView = self.collectionView else {
            return
        }
        let baseURL = "http://mobile-demo.outbrain.com/2013/12/15/test-page-2"
        self.smartFeedManager = SmartFeedManager(url: baseURL, widgetID: "SDK_1", collectionView: collectionView)
        self.smartFeedManager.delegate = self
        let bundle = Bundle.main
        let horizontalCellNib = UINib(nibName: "AppSFHorizontalItemCell", bundle: bundle)
        let singleCellNib = UINib(nibName: "AppSFSingleCell", bundle: bundle)
        self.smartFeedManager.registerHorizontalItemNib(horizontalCellNib, forCellWithReuseIdentifier: "AppSFHorizontalItemCell")
        self.smartFeedManager.registerSingleItemNib(singleCellNib, forCellWithReuseIdentifier: "AppSFSingleCell")
    }
}


// MARK: - UICollectionViewDataSource
extension ArticleCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.smartFeedManager.outbrainRecs.count > 0) ? 2 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return originalArticleItemsCount
        }
        else {
            return self.smartFeedManager.outbrainRecs.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UICollectionViewCell?
        
        if indexPath.section == 1 { // Outbrain
            return self.smartFeedManager.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
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
        case 5:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: outbrainHeaderCellReuseIdentifier,
                                                      for: indexPath)
        default:
            break
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.smartFeedManager.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // App Developer should configure the app cells here..
    }
}

extension ArticleCollectionViewController : SmartFeedDelegate {
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(rec.content).")
        guard let url = Outbrain.getUrl(rec) else {
            print("Error: no url for rec.")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}

extension ArticleCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        
        if indexPath.section == 1 { // Outbrain
            return CGSize(width: width - 20.0, height: 250.0)
        }
        
        switch indexPath.row {
        case 0:
            return CGSize(width: width, height: 200.0)
        case 1:
            return CGSize(width: width, height: 120.0)
        case 2,3,4:
            return CGSize(width: width, height: 200.0)
        case 5:
            return CGSize(width: width, height: 50)
        default:
            break
        }
        return CGSize(width: width, height: 200.0)
    }
}


