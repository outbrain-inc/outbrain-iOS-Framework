//
//  ArticleReadMoreTableViewController.swift
//  OutbrainDemo
//
//  Created by Alon Shprung on 30/11/2020.
//  Copyright © 2020 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices

import OutbrainSDK

class ArticleReadMoreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCell"
    private let contentCellReuseIdentifier = "contentHeaderCell"
    private let originalArticleItemsCount = 6
    private let isReadMoreModuleEnabled = true
    private let collapsableItemCount = 3
    private let collapsableSection = 1
    private var outbrainIdx = 0
    private var isLoadingOutrainRecs = false
    private var smartFeedManager: SmartFeedManager!
    private let paramsViewModel: ParamsViewModel
    
    
    init(paramsViewModel: ParamsViewModel) {
        self.paramsViewModel = paramsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        setupSmartFeed()
    }
    
    func setupSmartFeed() {
        smartFeedManager = SmartFeedManager(
            url: paramsViewModel.articleURL,
            widgetID: paramsViewModel.widgetId,
            tableView: self.tableView
        )
        
        smartFeedManager.delegate = self
        if (isReadMoreModuleEnabled) {
            smartFeedManager.setReadMoreModule()
        }
        smartFeedManager.darkMode = paramsViewModel.darkMode
        view.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white;
        tableView.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white;
        
        // self.smartFeedManager.disableCellShadows = true
        // self.smartFeedManager.displaySourceOnOrganicRec = true
        // self.smartFeedManager.horizontalContainerMargin = 40.0
        
        // Optional
        setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
//        let bundle = Bundle.main
        
        // Read more button custom UI
//        let readMoreCellNib = UINib(nibName: "AppSFTableViewReadMoreCell", bundle: bundle)
        
        // self.smartFeedManager.register(readMoreCellNib, withReuseIdentifier: "AppSFTableViewReadMoreCell", for: SFTypeReadMoreButton)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        smartFeedManager.outbrainSectionIndex = 2 // update smartFeedManager with outbrain section index, must be the last one.
        return smartFeedManager.numberOfSectionsInTableView()
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < smartFeedManager.outbrainSectionIndex {
            // For read more module
            if section == collapsableSection {
                return smartFeedManager.tableView(
                    tableView,
                    numberOfRowsInCollapsableSection: section,
                    collapsableItemCount: collapsableItemCount
                )
            } else {
                return originalArticleItemsCount - collapsableItemCount
            }
        }
        else {
            return smartFeedManager.smartFeedItemsCount()
            // return 24 // Test Sky Solution
        }
    }
        
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
        if indexPath.section == smartFeedManager.outbrainSectionIndex { // Outbrain
            return smartFeedManager.tableView(tableView, cellForRowAt: indexPath)
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cell = tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case (0,1):
            cell = tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        case (0,2), (1,_):
            cell = tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
            break
        }
        
        return cell ?? UITableViewCell()
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        smartFeedManager.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        // App Developer should configure the app cells here..
        if indexPath.section == 0 && indexPath.row == 1 {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
            }
        }
        if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 2)) {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == smartFeedManager.outbrainSectionIndex { // Outbrain
            let height = smartFeedManager.tableView(tableView, heightForRowAt: indexPath)
            return height
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

extension ArticleReadMoreTableViewController : SmartFeedDelegate {
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
}
