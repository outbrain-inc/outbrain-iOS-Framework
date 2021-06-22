//
//  TableVC.swift
//  SFWebView-Dev
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class TableVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    let textHeaderCellReuseIdentifier = "textHeaderCell"
    let contentCellReuseIdentifier = "contentHeaderCell"
    
    var sfWidget: SFWidget!
    
    let originalArticleItemsCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SFWidgetTableViewCell.self, forCellReuseIdentifier: "SFWidgetCell")
        
        sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        sfWidget.setProperties(
            delegate: self,
            url: "http://mobile-demo.outbrain.com",
            widgetId: "MB_1",
            installationKey: "NANOWDGT01"
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        sfWidget.viewWillTransition(coordinator: coordinator)
    }
    
    // MARK: UITableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return originalArticleItemsCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        case 2,3,4:
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
        default:
            if let sfWidgetCell = self.tableView.dequeueReusableCell(withIdentifier: "SFWidgetCell") as? SFWidgetTableViewCell {
                cell = sfWidgetCell
            }
            break;
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = UIColor.black
            }
        case 2,3,4:
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = UIColor.black
            }
        default:
            if let sfWidgetCell = cell as? SFWidgetTableViewCell {
                sfWidget.willDisplaySFWidgetCell(cell: sfWidgetCell)
            }
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return UIDevice.current.userInterfaceIdiom == .pad ? 400 : 250;
        case 1:
            return UIDevice.current.userInterfaceIdiom == .pad ? 150 : UITableView.automaticDimension;
        case 2, 3, 4:
            return UIDevice.current.userInterfaceIdiom == .pad ? 200 : UITableView.automaticDimension;
        default:
            return self.sfWidget.getCurrentHeight();
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget.scrollViewDidScroll(scrollView: scrollView)
    }
}


// MARK: SFWidgetDelegate
extension TableVC: SFWidgetDelegate {
    func didChangeHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
//    func onOrganicRecClick(url: URL) {
//        // handle click on organic url
//    }
    
    func onRecClick(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
