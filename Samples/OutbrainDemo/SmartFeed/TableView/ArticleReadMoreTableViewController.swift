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
    
    let darkMode = false
    let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    let textHeaderCellReuseIdentifier = "textHeaderCell"
    let contentCellReuseIdentifier = "contentHeaderCell"
    
    let originalArticleItemsCount = 6
    
    // For read more module
    let isReadMoreModuleEnabled = true
    let collapsableItemCount = 3
    let collapsableSection = 1
    
    var outbrainIdx = 0
    var isLoadingOutrainRecs = false
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        self.setupSmartFeed()
    }
    
    func setupSmartFeed() {
        self.smartFeedManager = SmartFeedManager(url: OBConf.baseURL, widgetID: OBConf.widgetID, tableView: self.tableView)
        self.smartFeedManager.delegate = self
        if (isReadMoreModuleEnabled) {
            self.smartFeedManager.setReadMoreModule()
        }
        self.smartFeedManager.darkMode = self.darkMode
        self.view.backgroundColor = self.darkMode ? UIColor.black : UIColor.white;
        self.tableView.backgroundColor = self.darkMode ? UIColor.black : UIColor.white;
        
        // self.smartFeedManager.disableCellShadows = true
        // self.smartFeedManager.displaySourceOnOrganicRec = true
        // self.smartFeedManager.horizontalContainerMargin = 40.0
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        
        // Read more button custom UI
        let readMoreCellNib = UINib(nibName: "AppSFTableViewReadMoreCell", bundle: bundle)
        
        self.smartFeedManager.register(readMoreCellNib, withReuseIdentifier: "AppSFTableViewReadMoreCell", for: SFTypeReadMoreButton)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.smartFeedManager.outbrainSectionIndex = 2 // update smartFeedManager with outbrain section index, must be the last one.
        return self.smartFeedManager.numberOfSectionsInTableView()
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.smartFeedManager.outbrainSectionIndex {
            // For read more module
            if section == self.collapsableSection {
                return self.smartFeedManager.tableView(tableView, numberOfRowsInCollapsableSection: section, collapsableItemCount: self.collapsableItemCount)
            } else {
                return self.originalArticleItemsCount - self.collapsableItemCount
            }
        }
        else {
            return self.smartFeedManager.smartFeedItemsCount()
            // return 24 // Test Sky Solution
        }
    }
        
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, cellForRowAt: indexPath)
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case (0,1):
            cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        case (0,2), (1,_):
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
        default:
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
            break;
        }
        
        return cell ?? UITableViewCell()
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.smartFeedManager.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        // App Developer should configure the app cells here..
        if indexPath.section == 0 && indexPath.row == 1 {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = self.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = self.darkMode ? UIColor.white : UIColor.black
            }
        }
        if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 2)) {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = self.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = self.darkMode ? UIColor.white : UIColor.black
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            let height = self.smartFeedManager.tableView(tableView, heightForRowAt: indexPath)
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
}
