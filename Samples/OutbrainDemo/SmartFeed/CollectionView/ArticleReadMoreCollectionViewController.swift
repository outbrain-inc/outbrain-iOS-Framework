//
//  ArticleReadMoreCollectionViewController.swift
//  OutbrainDemo
//
//  Created by Alon Shprung on 30/11/2020.
//  Copyright © 2020 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices
import AdSupport
import AppTrackingTransparency
import OutbrainSDK

class ArticleReadMoreCollectionViewController: UICollectionViewController {
    
    let darkMode = false
    let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    let contentCellReuseIdentifier = "contentCollectionCell"
    let outbrainRecCellReuseIdentifier = "outbrainRecCollectionCell"
    var refresher:UIRefreshControl!
    
    fileprivate let itemsPerRow: CGFloat = 1
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    let originalArticleItemsCount = 6
    
    // For read more module
    let isReadMoreModuleEnabled = true
    let collapsableItemCount = 3
    let collapsableSection = 1

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        
        setupSmartFeed()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.blue
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { authStatus in
                print("user authStatus is: \(authStatus)")
                print("advertisingIdentifier: \(ASIdentifierManager.shared().advertisingIdentifier)")
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Why are you shaking me?")
            self.showAlert()
        }
    }
    
    func showAlert() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Edit Fields", message: "Please edit the fields below", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Parent Widget ID"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Page URL"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let widgetID = alert?.textFields?[0].text, var urlString = alert!.textFields?[1].text {
                print("widgetID: \(widgetID)")
                print("url: \(urlString)")
                
                OBConf.widgetID = widgetID;
                
                if (urlString.starts(with: "www")) {
                    urlString = "https://" + urlString
                }
                if (self.verifyUrl(urlString: urlString)) {
                    OBConf.baseURL = urlString
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: "URL is not valid (\(urlString))", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                let successAlert = UIAlertController(title: "Success", message: "Smartfeed will reload with new fields (\(widgetID)) (\(urlString))", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(successAlert, animated: true, completion: {
                    self.loadData()
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
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
        
        
        self.smartFeedManager = SmartFeedManager(url: OBConf.baseURL, widgetID: OBConf.widgetID, collectionView: collectionView)
        
        self.smartFeedManager.delegate = self
        self.smartFeedManager.darkMode = self.darkMode
        self.collectionView.backgroundColor = self.darkMode ? UIColor.black : UIColor.white;
        
        if self.isReadMoreModuleEnabled {
            self.smartFeedManager.setReadMoreModule()
        }
        
        // self.smartFeedManager.displaySourceOnOrganicRec = true
        // self.smartFeedManager.horizontalContainerMargin = 40.0
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        
        // Read more button custom UI
        let readMoreCellNib = UINib(nibName: "AppSFCollectionViewReadMoreCell", bundle: bundle)
        
        self.smartFeedManager.register(readMoreCellNib, withReuseIdentifier: "AppSFCollectionViewReadMoreCell", for: SFTypeReadMoreButton)
    }
}


// MARK: - UICollectionViewDataSource
extension ArticleReadMoreCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.smartFeedManager.outbrainSectionIndex = 2 // update smartFeedManager with outbrain section index, must be the last one.
        return self.smartFeedManager.numberOfSectionsInCollectionView()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section < self.smartFeedManager.outbrainSectionIndex {
            // For read more module
            if section == self.collapsableSection {
                return self.smartFeedManager.collectionView(collectionView, numberOfItemsInCollapsableSection: section, collapsableItemCount: self.collapsableItemCount)
            } else {
                return self.originalArticleItemsCount - self.collapsableItemCount
            }
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
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case (0,1):
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: textHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case (0,2),(1,_):
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
        if (indexPath.section == 0 && indexPath.row == 1) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = self.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = self.darkMode ? UIColor.white : UIColor.black
                
            }
        }
        if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 2)) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = self.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = self.darkMode ? UIColor.white : UIColor.black
            }
        }
    }
}

extension ArticleReadMoreCollectionViewController : SmartFeedDelegate {
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(rec.content).")
        if rec.isAppInstall {
            print("rec tapped: \(rec.content) - is App Install");
            Outbrain.openAppInstallRec(rec, inNavController: self.navigationController!)
            return;
        }
        
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

extension ArticleReadMoreCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.size.width
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex {
            return self.smartFeedManager.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return CGSize(width: width, height: 0.5625*width)
        case (0,1):
            return CGSize(width: width, height: 0.35*width)
        case (1,_):
            return CGSize(width: width, height: 200.0)
        default:
            break
        }
        return CGSize(width: width, height: 200.0)
    }
}


