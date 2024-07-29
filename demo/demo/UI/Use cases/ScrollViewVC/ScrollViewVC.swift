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

class ScrollViewVC : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sfWidget: SFWidget!
    @IBOutlet weak var sfWidgetHeightConstraint: NSLayoutConstraint!
    
    private let paramsViewModel: ParamsViewModel
    
    
    init(paramsViewModel: ParamsViewModel) {
        self.paramsViewModel = paramsViewModel
        super.init(nibName: "ScrollViewVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sfWidget.configure(
            with: self,
            url: paramsViewModel.articleURL,
            widgetId: paramsViewModel.bridgeWidgetId,
            widgetIndex: 0,
            installationKey: "NANOWDGT01",
            userId: nil,
            darkMode: paramsViewModel.darkMode
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        sfWidget.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.contentView.frame.size.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget.scrollViewDidScroll(scrollView)
    }
}


// MARK: SFWidgetDelegate
extension ScrollViewVC: SFWidgetDelegate {
    
    func didChangeHeight() {
        sfWidgetHeightConstraint.constant = sfWidget.getCurrentHeight()
    }
    
    func onOrganicRecClick(_ url: URL) {
        // handle click on organic url
        let safariVC = SFSafariViewController(url: url)
        navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func onRecClick(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func widgetEvent(_ eventName: String, additionalData: [String : Any]) {
        print("App received widgetEvent: **\(eventName)** with data: \(additionalData)")
    }
}
