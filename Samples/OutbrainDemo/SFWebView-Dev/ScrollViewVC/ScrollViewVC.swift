//
//  ScrollViewVC.swift
//  SFWebView-Dev
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices
import OutbrainSDK

class ScrollViewVC : UIViewController, UIScrollViewDelegate, OBViewController {
    var widgetId: String = OBConf.smartFeedWidgetID
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sfWidget: SFWidget!
    
    @IBOutlet weak var sfWidgetHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sfWidget.configure(with: self, url: OBConf.baseURL, widgetId: self.widgetId, installationKey: OBConf.installationKey)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sfWidget.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.contentView.frame.size.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.sfWidget.scrollViewDidScroll(scrollView)
    }
}

// MARK: SFWidgetDelegate
extension ScrollViewVC: SFWidgetDelegate {
    func didChangeHeight() {
        self.sfWidgetHeightConstraint.constant = self.sfWidget.getCurrentHeight()
    }
    
    func onOrganicRecClick(_ url: URL) {
        // handle click on organic url
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func onRecClick(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
