//
//  ScrollViewTwoWidgets.swift
//  demo
//
//  Created by Leonid Lemesev on 30/07/2024.
//

import Foundation
import UIKit
import SafariServices
import OutbrainSDK


class ScrollViewTwoWidgets : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sfWidget1: SFWidget!
    @IBOutlet weak var sfWidget2: SFWidget!
    @IBOutlet weak var sfWidget1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sfWidget2HeightConstraint: NSLayoutConstraint!
    
    private let paramsViewModel: ParamsViewModel
    
    
    init(paramsViewModel: ParamsViewModel) {
        self.paramsViewModel = paramsViewModel
        super.init(nibName: "ScrollViewTwoWidgets", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sfWidget1.configure(
            with: self,
            url: paramsViewModel.articleURL,
            widgetId: paramsViewModel.bridgeWidgetId,
            widgetIndex: 0,
            installationKey: "NANOWDGT01",
            userId: nil,
            darkMode: paramsViewModel.darkMode
        )
        
        sfWidget2.configure(
            with: self,
            url: paramsViewModel.articleURL,
            widgetId: paramsViewModel.bridgeWidgetId,
            widgetIndex: 1,
            installationKey: "NANOWDGT01",
            userId: nil,
            darkMode: paramsViewModel.darkMode
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sfWidget1.viewWillTransition(to: size, with: coordinator)
        sfWidget2.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.frame.size.width,
                height: self.contentView.frame.size.height
            )
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget1.scrollViewDidScroll(scrollView)
        sfWidget2.scrollViewDidScroll(scrollView)
    }
}


// MARK: SFWidgetDelegate
extension ScrollViewTwoWidgets: SFWidgetDelegate {
    
    func didChangeHeight() {
        sfWidget1HeightConstraint.constant = sfWidget1.getCurrentHeight()
        sfWidget2HeightConstraint.constant = sfWidget2.getCurrentHeight()
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

