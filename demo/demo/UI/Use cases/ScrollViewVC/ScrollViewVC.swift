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
    @IBOutlet weak var bottomContentTextView: UITextView!
    @IBOutlet weak var sfWidget: SFWidget!
    @IBOutlet weak var sfWidgetHeightConstraint: NSLayoutConstraint!
    
    private let paramsViewModel: ParamsViewModel
    private let isRegular: Bool
    
    
    init(paramsViewModel: ParamsViewModel, isRegular: Bool = false) {
        self.paramsViewModel = paramsViewModel
        self.isRegular = isRegular
        super.init(nibName: "ScrollViewVC", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRegular {
            sfWidgetHeightConstraint.constant = 0
            sfWidget.isHidden = true
            
            let request = OBRequest(
                url: paramsViewModel.articleURL,
                widgetID: paramsViewModel.regularWidgetId,
                widgetIndex: 0
            )
            
            
            Outbrain.fetchRecommendations(for: request) { response in
                response.recommendations.enumerated().forEach { element in
                    DispatchQueue.main.async {
                        let view = RecommendationView(rec: element.element)
                        view.translatesAutoresizingMaskIntoConstraints = false
                        self.scrollView.addSubview(view)
                        
                        NSLayoutConstraint.activate([
                            view.topAnchor.constraint(equalTo: self.bottomContentTextView.bottomAnchor, constant: CGFloat(100 * element.offset)),
                            view.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
                            view.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
                            view.heightAnchor.constraint(equalToConstant: 100),
                            view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: CGFloat(100 * (response.recommendations.count - element.offset - 2)))
                        ])
                        
                        view.layoutIfNeeded()
                        Outbrain.configureViewabilityPerListing(for: view, withRec: element.element)
                        
                        view.addTapGestureRecognizer {
                            self.recClick(urlString: element.element.url)
                        }
                    }
                }
            }
        } else {
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
    }
    
    
    
    @objc func recClick(urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else { return }
        onRecClick(url)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sfWidget.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.frame.size.width,
                height: self.contentView.frame.size.height
            )
        }
    }
}


// MARK: SFWidgetDelegate
extension ScrollViewVC: SFWidgetDelegate {
    
    func didChangeHeight(_ newHeight: CGFloat) {
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


extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
