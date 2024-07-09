//
//  ArticleMidPageTableViewController.swift
//  OutbrainDemo
//
//  Created by oded regev on 17/06/2019.
//  Copyright © 2019 Outbrain inc. All rights reserved.
//


import UIKit
import SafariServices

import OutbrainSDK

class ArticleMidPageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCell"
    private let contentCellReuseIdentifier = "contentHeaderCell"
    private var smartfeedIsReady = false
    private let articleSectionItemsCount = 5
    private let articleTotalItemsCount = 10
    private var outbrainIdx = 0
    private var isLoadingOutrainRecs = false
    private var smartFeedManager:SmartFeedManager!
    private let paramsViewModel: ParamsViewModel
    
    init(paramsViewModel: ParamsViewModel) {        
        self.paramsViewModel = paramsViewModel
        super.init(nibName: nil, bundle: nil)
        setupSmartFeed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        self.setupSmartFeed()
    }
    
    func setupSmartFeed() {
        smartFeedManager = SmartFeedManager(
            url: paramsViewModel.articleURL,
            widgetID: paramsViewModel.widgetId,
            tableView: self.tableView
        )
        
        smartFeedManager.delegate = self
        smartFeedManager.isInMiddleOfScreen = true
        smartFeedManager.outbrainSectionIndex = 1 // update smartFeedManager with outbrain section index
        smartFeedManager.fetchMoreRecommendations() // start fetching manually because Smartfeed is in the middle
        
        // self.smartFeedManager.displaySourceOnOrganicRec = true
        // self.smartFeedManager.horizontalContainerMargin = 40.0
        
        // Optional
        setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
//        let bundle = Bundle.main
//        let fixedhorizontalCellNib = UINib(nibName: "AppSFHorizontalFixedItemCell", bundle: bundle)
//        let singleCellNib = UINib(nibName: "AppSFSingleWithTitleTableViewCell", bundle: bundle)
//        
//        let headerCellNib = UINib(nibName: "AppSFTableViewHeaderCell", bundle: bundle)
        
        // self.smartFeedManager.register(headerCellNib, withReuseIdentifier: "AppSFTableViewHeaderCell", for: SFTypeSmartfeedHeader)
        // self.smartFeedManager.register(horizontalCellNib, withCellWithReuseIdentifier: "AppSFHorizontalItemCell",forWidgetId: "SFD_MAIN_2")
        // self.smartFeedManager.register(fixedhorizontalCellNib, withReuseIdentifier: "AppSFHorizontalFixedItemCell", forWidgetId: "SFD_MAIN_2")
        // self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleWithTitleTableViewCell", forWidgetId: "SDK_SFD_1")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.smartfeedIsReady {
            // numberOfSections including Smartfeed
            return 3
        }
        else {
            return 2
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.smartfeedIsReady && section == self.smartFeedManager.outbrainSectionIndex {
            return self.smartFeedManager.smartFeedItemsCount()
        }
        else {
            return articleSectionItemsCount
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
        if self.smartfeedIsReady && indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, cellForRowAt: indexPath)
        }
        
        switch indexPath.row {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        case 2,3,4:
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
        default:
            break;
        }
        
        return cell ?? UITableViewCell()
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.smartfeedIsReady && indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            self.smartFeedManager.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            return
        }
        
        // App Developer should configure the app cells here..
        if (indexPath.row == 1) {
            if let articleCell = cell as? AppArticleTableViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
            }
        }
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            if let articleCell = cell as? AppArticleTableViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.smartfeedIsReady && indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, heightForRowAt: indexPath)
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return UIDevice.current.userInterfaceIdiom == .pad ? 400 : 250;
            }
            else if (indexPath.row == 1) {
                return UIDevice.current.userInterfaceIdiom == .pad ? 150 : UITableView.automaticDimension;
            }
            else {
                return UIDevice.current.userInterfaceIdiom == .pad ? 200 : UITableView.automaticDimension;
            }
        }
        
        return UITableView.automaticDimension;
    }
}

extension ArticleMidPageTableViewController : SmartFeedDelegate {
    func userTappedOnOutbrainLabeling() {
        print("You tapped on Outbrain Labeling")
        let url = Outbrain.getAboutURL()
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(String(describing: rec.content)).")
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
    
    func smartfeedIsReadyWithRecs() {
        // Do what is needed to integrate the Smartfeed content in the UITableView
        self.smartfeedIsReady = true
        self.tableView.reloadData()
    }
    
    // Optional
    //    func carouselItemSize() -> CGSize {
    //        return CGSize(width: 300, height: 200)
    //    }
}
