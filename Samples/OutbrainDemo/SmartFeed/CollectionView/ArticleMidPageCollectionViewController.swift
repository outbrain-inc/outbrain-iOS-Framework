//
//  ArticleMidPageCollectionViewController.swift
//  SmartFeed
//
//  Created by oded regev on 17/06/2019.
//  Copyright © 2019 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices

import OutbrainSDK

class ArticleMidPageCollectionViewController: UICollectionViewController {
    
    let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    let contentCellReuseIdentifier = "contentCollectionCell"
    let outbrainRecCellReuseIdentifier = "outbrainRecCollectionCell"
    var refresher:UIRefreshControl!
    
    fileprivate let itemsPerRow: CGFloat = 1
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    let originalArticleItemsCount = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSmartFeed()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.blue
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    @objc func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.stopRefresher()
            self.setupSmartFeed()
            self.collectionView?.reloadData()
        })
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupSmartFeed() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        
        self.smartFeedManager = SmartFeedManager(url: Const.baseURL, widgetID: Const.widgetID, collectionView: collectionView)
        
        self.smartFeedManager.delegate = self
        
        // self.smartFeedManager.displaySourceOnOrganicRec = true
        // self.smartFeedManager.horizontalContainerMargin = 40.0
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        let fixedhorizontalCellNib = UINib(nibName: "AppSFHorizontalFixedItemCell", bundle: bundle)
        let carouselHorizontalCellNib = UINib(nibName: "AppSFHorizontalItemCell", bundle: bundle)
        let singleCellNib = UINib(nibName: "AppSFSingleWithTitleCollectionViewCell", bundle: bundle)
        let headerCellNib = UINib(nibName: "AppSFCollectionViewHeaderCell", bundle: bundle)
        
        
        // Example - un-comment to see how Smartfeed custom-UI works.
        // self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleWithTitleCollectionViewCell", for: SFTypeStripWithTitle)
        // self.smartFeedManager.register(headerCellNib, withReuseIdentifier: "AppSFCollectionViewHeaderCell", for: SFTypeSmartfeedHeader)
        // self.smartFeedManager.register(fixedhorizontalCellNib, withReuseIdentifier: "AppSFHorizontalFixedItemCell", forWidgetId: "SFD_MAIN_5")
        // self.smartFeedManager.register(carouselHorizontalCellNib, withReuseIdentifier: "AppSFHorizontalItemCell", forWidgetId: "SDK_SFD_5")
        // self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleWithTitleCollectionViewCell", forWidgetId: "SDK_SFD_1")
    }
}


// MARK: - UICollectionViewDataSource
extension ArticleMidPageCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.smartFeedManager.outbrainSectionIndex = 1 // update smartFeedManager with outbrain section index, must be the last one.
        return self.smartFeedManager.numberOfSectionsInCollectionView()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section < self.smartFeedManager.outbrainSectionIndex {
            return originalArticleItemsCount
        }
        else {
            return self.smartFeedManager.smartFeedItemsCount()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UICollectionViewCell?
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex {
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
        default:
            break
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.smartFeedManager.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex {
            return
        }
        
        // App Developer should configure the app cells here..
        if (indexPath.row == 1) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
            }
        }
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
            }
        }
    }
}

extension ArticleMidPageCollectionViewController : SmartFeedDelegate {
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(rec.content).")
        guard let url = Outbrain.getUrl(rec) else {
            print("Error: no url for rec.")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTapped(onAdChoicesIcon url: URL) {
        print("You tapped onAdChoicesIcon")
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTapped(onVideoRec url: URL) {
        print("You tapped on video rec")
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTappedOnOutbrainLabeling() {
        print("You tapped on Outbrain Labeling")
        let url = Outbrain.getAboutURL()
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    
}

extension ArticleMidPageCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex {
            return self.smartFeedManager.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        
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
        return CGSize(width: width, height: 200.0)
    }
}



