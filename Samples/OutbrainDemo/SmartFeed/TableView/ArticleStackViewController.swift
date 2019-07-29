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

class ArticleStackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // This example use the following links:
    // https://stackoverflow.com/questions/42437966/how-to-adjust-height-of-uicollectionview-to-be-the-height-of-the-content-size-of
    // https://stackoverflow.com/questions/31668970/is-it-possible-for-uistackview-to-scroll

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sfCollectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sfCollectionViewHeight: NSLayoutConstraint!
    
    
    let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    let textHeaderCellReuseIdentifier = "textHeaderCell"
    let contentCellReuseIdentifier = "contentHeaderCell"
    
    let originalArticleItemsCount = 5
    var outbrainIdx = 0
    var isLoadingOutrainRecs = false
    var smartFeedManager:SmartFeedManager = SmartFeedManager() // temp initilization, will be replaced in viewDidLoad
    var smartfeedIsReady = false
    var lastFetchMoreRecommendationFireTime = NSDate().timeIntervalSince1970
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        tableView.isScrollEnabled = false
        sfCollectionView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        self.setupSmartFeed()
    }
    
    func setupSmartFeed() {
        self.smartFeedManager = SmartFeedManager(url: OBConf.baseURL, widgetID: OBConf.widgetID, collectionView: self.sfCollectionView)
        self.smartFeedManager.delegate = self
        self.smartFeedManager.isInMiddleOfScreen = true
        self.smartFeedManager.outbrainSectionIndex = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            self.smartFeedManager.fetchMoreRecommendations() // start fetching manually because Smartfeed is in the middle
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return originalArticleItemsCount
    }
        
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell?
        
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
        
        if (indexPath.row == originalArticleItemsCount-1) {
            let height = self.tableView.contentSize.height
            print("set tableView height to: \(height)")
            self.tableViewHeight.constant = height
            self.view.setNeedsLayout()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

extension ArticleStackViewController : SmartFeedDelegate {
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

    func smartfeedIsReadyWithRecs() {
        if (!self.smartfeedIsReady) {
            // only for the first time run reloadData() after that the Smartfeed will take care of updating itself
            self.smartfeedIsReady = true
            self.sfCollectionView.reloadData()
        }
        let height = self.sfCollectionView.collectionViewLayout.collectionViewContentSize.height
        print("set collectionview height to: \(height)")
        self.sfCollectionViewHeight.constant = height
        self.view.setNeedsLayout()
    }
}


// Smartfeed Collection View
extension ArticleStackViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.smartFeedManager.numberOfSectionsInCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        // There is only 1 section and it's the Smartfeed
        return self.smartFeedManager.smartFeedItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // create a new cell if needed or reuse an old one
        return self.smartFeedManager.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.smartFeedManager.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
}

extension ArticleStackViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.smartFeedManager.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
}


extension ArticleStackViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 400 >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if (self.smartFeedManager.hasMore) {
                if self.lastFetchMoreRecommendationFireTime + 0.4 < NSDate().timeIntervalSince1970 {
                    self.lastFetchMoreRecommendationFireTime = NSDate().timeIntervalSince1970
                    print("App calling fetchMoreRecommendations()")
                    self.smartFeedManager.fetchMoreRecommendations()
                }
            }
        }
    }
    
    @objc func fetchMoreRecommendations() {
        
    }
    func debounce(interval: Int, queue: DispatchQueue, action: @escaping (() -> Void)) -> () -> Void {
        var lastFireTime:DispatchTime = DispatchTime.init(uptimeNanoseconds: 0)
        let dispatchDelay = DispatchTimeInterval.milliseconds(interval)
        
        return {
            lastFireTime = DispatchTime.now()
            let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
            
            queue.asyncAfter(deadline: dispatchTime) {
                let when: DispatchTime = lastFireTime + dispatchDelay
                let now = DispatchTime.now()
                if now.rawValue >= when.rawValue {
                    action()
                }
            }
        }
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
