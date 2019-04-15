//
//  ArticleTableViewController.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/1/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import OutbrainSDK
import SafariServices

class ArticleTableViewController: UITableViewController {
    static let kHeaderCellIdentifier = "HeaderCell"
    static let kImageCellIdentifier = "ImageCell"
    static let kContentCellIndentifier = "ContentCell"
    
    let kNetowrkErrorMsg = "Unable to fetch article from the server"
    
    var post:Post?
    
    fileprivate var image:UIImage?
    fileprivate var outbrainFooterView:OutbrainFooterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OBHelper.addOutbrainLogoTopBar(self)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.reloadData()
        
        self.outbrainFooterView = OutbrainFooterView.loadFromNib()
        self.outbrainFooterView!.delegate = self
        self.tableView.tableFooterView = self.outbrainFooterView
        
        loadPageContentOnScreen()
    }
}

extension ArticleTableViewController : OutbrainFooterViewDelegate {

    func heightHasChanged() {
        self.tableView.tableFooterView = self.outbrainFooterView
    }
    
    func userTappedRecommendation(_ rec:OBRecommendation) {
        guard let url = Outbrain.getUrl(rec) else {
            print("Outbrain.getUrl(rec) - url is null")
            return
        }
        
        if (rec.isPaidLink) {
            // Open all paid recommendation in SFSafariViewController
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
        else {
            // It's a an organic recommendation, let's open it in our native Article ViewController
            loadPostContentFromUrl(url)
        }
    }
    
    func userTappedOnAdChoicesIcon(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func userTappedOnOutbrainLogo() {
        OBHelper.showOutbrainOnWebView(self)
    }

}

extension ArticleTableViewController { // Private
    
    func loadPageContentOnScreen() {
        let postURL = (post?.url)!
        OBNetworkManager.sharedInstance.fetchOutbrainRecommendations(postURL, completion: { recs in
            if (recs != nil) {
                
                // Important - The most important step in the Widget Viewability implementation is to register
                // the OBLabel with the corresponding widgetID and URL of the page.
                // For the full explanation please refer to: http://developer.outbrain.com/ios-sdk-2-0-pre-release/#widget_viewability
                if let headerOBLabel = self.outbrainFooterView!.outbrainHeaderView?.recommendedToYouLabel {
                    Outbrain.register(headerOBLabel, withWidgetId: OBNetworkManager.kOB_DEMO_WIDGET_ID, andUrl: postURL)
                }
                
                self.outbrainFooterView!.recs = recs!
                self.outbrainFooterView!.tableView.reloadData()
            }
        })
        
        if (post?.imageURL != nil) {
            
            let imageUrl = (post?.imageURL)!
            Alamofire.request(imageUrl).responseImage { response in                
                if let image = response.result.value {
                    self.image = image
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadPostContentFromUrl(_ url:URL) {
        OBHelper.startGlobalSpinner()
        
        OBNetworkManager.sharedInstance.loadSinglePostDataFromServer(url.absoluteString) {
            (post, error) -> Void in
            if post != nil {
                // Success
                self.post = post!
                self.loadPageContentOnScreen()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
            else {
                // Handle error
                OBHelper.displaySimpleAlert("Server Error", msg: self.kNetowrkErrorMsg, currentVC: self)
                self.refreshControl?.endRefreshing()
            }
            OBHelper.stopGlobalSpinner()
        }
    }
}

extension ArticleTableViewController {
    
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn:UITableViewCell? = nil
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewController.kHeaderCellIdentifier, for: indexPath) as! HeaderCell;
            cell.headlineLabel.text = self.post?.title
//            cell.dateLabel.text = self.post?.date
            cellToReturn = cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewController.kImageCellIdentifier, for: indexPath) as! ImageCell;
            if (self.image != nil) {
                cell.spinner.stopAnimating()
                cell.articleImage.image = self.image
            }
            else {
                cell.spinner.startAnimating()
            }
            
            
            
            cellToReturn = cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewController.kContentCellIndentifier, for: indexPath) as! ContentCell;

            let contentString = self.post?.content.stringByStrippingHTML
            cellToReturn = cell
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10.0
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.paragraphSpacing = 5
            paragraphStyle.paragraphSpacingBefore = 10
            let lightGrayTextColor = UIColor(red: 0.475, green: 0.475, blue: 0.475, alpha: 1.0)
        
            let attrs = [NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: lightGrayTextColor, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 14)! ]
            let articleAttributedString = NSAttributedString(string: contentString!, attributes: attrs)
            
            
            cell.contentTextView.attributedText = articleAttributedString
            
        default:
            break
        }
        
        return cellToReturn!
    }    
}


