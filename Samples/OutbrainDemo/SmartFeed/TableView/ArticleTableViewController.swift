//
//  ArticleTableViewController.swift
//  ios-SmartFeed
//
//  Created by oded regev on 1/30/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import SafariServices

import OutbrainSDK

class ArticleTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let smartFeedWidgetID = UIDevice.current.userInterfaceIdiom == .pad ? "SFD_MAIN_3" : "SFD_MAIN_2"
    // let smartFeedWidgetID = "SFD_MAIN_5"
    
    let currentArticleDemoUrl = "http://mobile-demo.outbrain.com/2013/12/15/test-page-2"
    let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    let textHeaderCellReuseIdentifier = "textHeaderCell"
    let contentCellReuseIdentifier = "contentHeaderCell"
    
    let originalArticleItemsCount = 5
    var outbrainIdx = 0
    var isLoadingOutrainRecs = false
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        self.tableView.tableFooterView = spinner;
        self.setupSmartFeed()
    }
    
    func setupSmartFeed() {
        let baseURL = currentArticleDemoUrl
        self.smartFeedManager = SmartFeedManager(url: baseURL, widgetID: smartFeedWidgetID, tableView: self.tableView)
        self.smartFeedManager.delegate = self
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        let fixedhorizontalCellNib = UINib(nibName: "AppSFHorizontalFixedItemCell", bundle: bundle)
        let singleCellNib = UINib(nibName: "AppSFSingleWithTitleTableViewCell", bundle: bundle)
        
        //self.smartFeedManager.register(horizontalCellNib, withCellWithReuseIdentifier: "AppSFHorizontalItemCell",f
        self.smartFeedManager.register(fixedhorizontalCellNib, withReuseIdentifier: "AppSFHorizontalFixedItemCell", forWidgetId: "SFD_MAIN_2")
        self.smartFeedManager.register(singleCellNib, withReuseIdentifier: "AppSFSingleWithTitleTableViewCell", forWidgetId: "SDK_SFD_1")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.smartFeedManager.outbrainSectionIndex = 1 // update smartFeedManager with outbrain section index, must be the last one.
        return self.smartFeedManager.numberOfSectionsInTableView()
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.smartFeedManager.outbrainSectionIndex {
            return originalArticleItemsCount
        }
        else {
            return self.smartFeedManager.smartFeedItemsCount()
        }
    }
        
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
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
        self.smartFeedManager.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
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
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, heightForRowAt: indexPath)
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return UIDevice.current.userInterfaceIdiom == .pad ? 400 : 250;
            }
            else if (indexPath.row == 1) {
                return UIDevice.current.userInterfaceIdiom == .pad ? 150 : UITableViewAutomaticDimension;
            }
            else {
                return UIDevice.current.userInterfaceIdiom == .pad ? 200 : UITableViewAutomaticDimension;
            }
        }

        return UITableViewAutomaticDimension;
    }
}

extension ArticleTableViewController : SmartFeedDelegate {
    func userTappedOnOutbrainLabeling() {
        print("You tapped on Outbrain Labeling")
        guard let url = Outbrain.getAboutURL() else {
            return
        }
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

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
