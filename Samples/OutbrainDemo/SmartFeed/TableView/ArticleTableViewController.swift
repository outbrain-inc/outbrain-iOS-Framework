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
    
    let smartFeedWidgetID = "SFD_MAIN_1"
    let currentArticleDemoUrl = "http://mobile-demo.outbrain.com/2013/12/15/test-page-2"
    let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    let textHeaderCellReuseIdentifier = "textHeaderCell"
    let contentCellReuseIdentifier = "contentHeaderCell"
    let outbrainHeaderCellReuseIdentifier = "outbrainHeaderCell"
    
    let originalArticleItemsCount = 6
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
        guard let publisherLogoImage = UIImage(named: "cnn-logo") else {
            return
        }
        let baseURL = currentArticleDemoUrl
        self.smartFeedManager = SmartFeedManager(url: baseURL, widgetID: smartFeedWidgetID, tableView: self.tableView, publisherName: "CNN", publisherImage: publisherLogoImage)
        self.smartFeedManager.delegate = self
        
        // Optional
        self.setupCustomUIForSmartFeed()
    }
    
    func setupCustomUIForSmartFeed() {
        let bundle = Bundle.main
        let horizontalCellNib = UINib(nibName: "AppSFHorizontalItemCell", bundle: bundle)
        let singleCellNib = UINib(nibName: "AppSFTableViewCell", bundle: bundle)
        self.smartFeedManager.registerHorizontalItemNib(horizontalCellNib, forCellWithReuseIdentifier: "AppSFHorizontalItemCell")
        self.smartFeedManager.registerSingleItemNib(singleCellNib, forCellWithReuseIdentifier: "AppSFTableViewCell")
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
            return self.smartFeedManager.smartFeedItemsArray.count
        }
    }
        
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, cellForRowAt: indexPath)
            //setCardView(cell: outbrainCell)
        }
        
        switch indexPath.row {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        case 2,3,4:
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
        case 5:
            cell = self.tableView.dequeueReusableCell(withIdentifier: outbrainHeaderCellReuseIdentifier) as UITableViewCell?
            
            if let obLabel = cell?.viewWithTag(455) as? OBLabel {
                Outbrain.register(obLabel, withWidgetId: smartFeedWidgetID, andUrl: currentArticleDemoUrl)
            }
        default:
            break;
        }
        
        return cell ?? UITableViewCell()
    }
    
    func setCardView(cell : UITableViewCell) {
        guard let view = cell.viewWithTag(99) else {
            return
        }
        view.backgroundColor = UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 0.5)
        view.layer.cornerRadius = 5.0
        view.layer.borderColor  =  UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.2
        view.layer.shadowColor =  UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 0.5).cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 5.0
        view.layer.shadowOffset = CGSize(width:5.0, height: 5.0)
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.smartFeedManager.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == self.smartFeedManager.outbrainSectionIndex { // Outbrain
            return self.smartFeedManager.tableView(tableView, heightForRowAt: indexPath)
        }
        
        return UITableViewAutomaticDimension;
    }
}

extension ArticleTableViewController : SmartFeedDelegate {
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
