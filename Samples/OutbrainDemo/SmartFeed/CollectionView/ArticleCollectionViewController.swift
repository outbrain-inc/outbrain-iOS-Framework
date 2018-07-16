
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
    var refresher:UIRefreshControl!
    
    fileprivate let itemsPerRow: CGFloat = 1
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    let originalArticleItemsCount = 6

    
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
        guard let publisherLogoImage = UIImage(named: "cnn-logo") else {
            return
        }
        let baseURL = "http://mobile-demo.outbrain.com/2013/12/15/test-page-2"
        self.smartFeedManager = SmartFeedManager(url: baseURL, widgetID: "SFD_MAIN_1", collectionView: collectionView, publisherName: "CNN", publisherImage: publisherLogoImage)
        
        self.smartFeedManager.delegate = self
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        let horizontalCellNib = UINib(nibName: "AppSFHorizontalItemCell", bundle: bundle)
        let singleCellNib = UINib(nibName: "AppSFCollectionViewCell", bundle: bundle)
        self.smartFeedManager.registerHorizontalItemNib(horizontalCellNib, forCellWithReuseIdentifier: "AppSFHorizontalItemCell")
        self.smartFeedManager.registerSingleItemNib(singleCellNib, forCellWithReuseIdentifier: "AppSFCollectionViewCell")
    }
}


// MARK: - UICollectionViewDataSource
extension ArticleCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.smartFeedManager.outbrainSectionIndex = 1 // update smartFeedManager with outbrain section index
        return self.smartFeedManager.numberOfSectionsInCollectionView()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section < self.smartFeedManager.outbrainSectionIndex {
            return originalArticleItemsCount
        }
        else {
            return self.smartFeedManager.smartFeedItemsArray.count
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
        case 5:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: outbrainHeaderCellReuseIdentifier,
                                                      for: indexPath)
            if let button = cell?.viewWithTag(33) as? UIButton {
                button.addTarget(self, action: #selector(self.outbrainLogoClicked), for: .touchUpInside)
            }
            
            if let obLabel = cell?.viewWithTag(455) as? OBLabel {
                Outbrain.register(obLabel, withWidgetId: self.smartFeedManager.widgetId, andUrl: self.smartFeedManager.url)
            }
            
        default:
            break
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.smartFeedManager.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // App Developer should configure the app cells here..
    }
    
    @objc private func outbrainLogoClicked() {
        guard let outbrainUrl = Outbrain.getAboutURL() else {
            return
        }
        let safariVC = SFSafariViewController(url: outbrainUrl)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
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
    
    func userTapped(onAdChoicesIcon url: URL) {
        print("You tapped onAdChoicesIcon")
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}

extension ArticleCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.size.width
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex {
            return self.smartFeedManager.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
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


