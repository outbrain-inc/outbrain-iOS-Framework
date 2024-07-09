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
    
    private let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCell"
    private let contentCellReuseIdentifier = "contentHeaderCell"
    private let originalArticleItemsCount = 5
    private var outbrainIdx = 0
    private var isLoadingOutrainRecs = false
    private var smartFeedManager: SmartFeedManager!
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
        setupSmartFeed()
    }
    
    
    func setupSmartFeed() {
        smartFeedManager = SmartFeedManager(
            url: paramsViewModel.articleURL,
            widgetID: paramsViewModel.widgetId,
            tableView: tableView
        )
        
        smartFeedManager.delegate = self
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
        smartFeedManager.outbrainSectionIndex = 1 // update smartFeedManager with outbrain section index, must be the last one.
        return smartFeedManager.numberOfSectionsInTableView()
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < smartFeedManager.outbrainSectionIndex {
            return originalArticleItemsCount
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
            return self.smartFeedManager.tableView(tableView, cellForRowAt: indexPath)
        }
        
        switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
            case 2,3,4:
                cell = tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
                break;
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
        if (indexPath.row == 1) {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
            }
        }
        
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = paramsViewModel.darkMode ? UIColor.black : UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = paramsViewModel.darkMode ? UIColor.white : UIColor.black
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

extension ArticleTableViewController : SmartFeedDelegate {
    func userTappedOnOutbrainLabeling() {
        print("You tapped on Outbrain Labeling")
        let url = Outbrain.getAboutURL()
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
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
    
    // Optional
    func reloadItemsOnOrientationChanged() -> Bool {
        return true
    }
    
    // Optional
    //    func carouselItemSize() -> CGSize {
    //        return CGSize(width: 300, height: 200)
    //    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
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
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
