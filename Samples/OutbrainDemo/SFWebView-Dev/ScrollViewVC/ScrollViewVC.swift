//
//  ScrollViewVC.swift
//  SFWebView-Dev
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices

class ScrollViewVC : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sfWidget: SFWidget!
    
    @IBOutlet weak var sfWidgetHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sfWidget.setProperties(
            delegate: self,
            url: "http://mobile-demo.outbrain.com",
            widgetId: "MB_1",
            installationKey: "NANOWDGT01"
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sfWidget.viewWillTransition(coordinator: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.contentView.frame.size.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.sfWidget.scrollViewDidScroll(scrollView: scrollView)
    }
}

// MARK: SFWidgetDelegate
extension ScrollViewVC: SFWidgetDelegate {
    func didChangeHeight() {
        //TODO change height
        self.sfWidgetHeightConstraint.constant = self.sfWidget.getCurrentHeight()
    }
    
//    func onOrganicRecClick(url: URL) {
//        // handle click on organic url
//    }
    
    func onRecClick(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
