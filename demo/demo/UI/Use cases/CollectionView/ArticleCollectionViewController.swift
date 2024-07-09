
//
//  ArticleCollectionViewController.swift
//  ios-SmartFeed
//
//  Created by Oded Regev on 2/4/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import SafariServices
import AdSupport
import AppTrackingTransparency
import OutbrainSDK

class ArticleCollectionViewController: UICollectionViewController {
    
    private let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    private let contentCellReuseIdentifier = "contentCollectionCell"
    private let outbrainRecCellReuseIdentifier = "outbrainRecCollectionCell"
    private var refresher: UIRefreshControl!
    private let itemsPerRow: CGFloat = 1
    private let originalArticleItemsCount = 5
    private var paramsViewModel: ParamsViewModel
    private var smartFeedManager: SmartFeedManager!
    
    
    init(
        collectionViewLayout: UICollectionViewLayout,
        paramsViewModel: ParamsViewModel
    ) {
        self.paramsViewModel = paramsViewModel
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        
        setupSmartFeed()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.blue
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white;
        
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
                
                //                OBConf.widgetID = widgetID;
                
                if (urlString.starts(with: "www")) {
                    urlString = "https://" + urlString
                }
                if (self.verifyUrl(urlString: urlString)) {
                    //                    OBConf.baseURL = urlString
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
    
    private func setupSmartFeed() {
        smartFeedManager = SmartFeedManager(
            url: paramsViewModel.articleURL,
            widgetID: paramsViewModel.widgetId,
            collectionView: collectionView
        )
        smartFeedManager.delegate = self
        smartFeedManager.darkMode = paramsViewModel.darkMode
    }
}


// MARK: - UICollectionViewDataSource
extension ArticleCollectionViewController {
    
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
        
        if (indexPath.row == 1) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
                
            }
        }
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
            }
        }
    }
}

extension ArticleCollectionViewController : SmartFeedDelegate {
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(String(describing: rec.content)).")
        if rec.isAppInstall {
            print("rec tapped: \(String(describing: rec.content)) - is App Install");
            Outbrain.openAppInstallRec(rec, in: self)
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
    
    func reloadItemsOnOrientationChanged() -> Bool {
        return false
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == self.smartFeedManager.outbrainSectionIndex {
            return self.smartFeedManager.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
        }
        return 5.0
    }
}


