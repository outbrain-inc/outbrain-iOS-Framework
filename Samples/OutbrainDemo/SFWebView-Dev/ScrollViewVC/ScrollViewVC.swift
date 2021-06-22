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
    
    var sfWidget: SFWidget!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let contentRect: CGRect = contentView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        scrollView.contentSize = contentRect.size
        
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget.scrollViewDidScroll(scrollView: scrollView)
    }
}

// MARK: SFWidgetDelegate
extension ScrollViewVC: SFWidgetDelegate {
    func didChangeHeight() {
        //TODO change height
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        scrollView.contentSize = contentRect.size
    }
    
//    func onOrganicRecClick(url: URL) {
//        // handle click on organic url
//    }
    
    func onRecClick(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
