//
//  OBHelper.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/10/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit
import SafariServices
import OutbrainSDK

class OBHelper {
    
    fileprivate static var __once: () = {
            createSpinnerOnScreen()
        }()
    
    static let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    static func displaySimpleAlert(_ title:String, msg:String, currentVC:UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handler))
        currentVC.present(alert, animated: true, completion: nil)
    }
    
    static func showOutbrainOnWebView(_ viewController:UIViewController) {
        let url = Outbrain.getAboutURL()
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    static func addOutbrainLogoTopBar(_ vc:UIViewController) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 30))
        let btnImage = UIImage(named: "outbrain-logo")
        let aboutOutbrainButton = UIButton(type: .custom)
        aboutOutbrainButton.frame = view.frame
        aboutOutbrainButton.setImage(btnImage, for: .normal)
        aboutOutbrainButton.imageView?.contentMode = .scaleAspectFit
        aboutOutbrainButton.addTarget(self, action: #selector(showOutbrainAbout(sender:)), for: .touchUpInside)
        view.addSubview(aboutOutbrainButton)
        vc.navigationItem.titleView = view
    }
    
    @objc static func showOutbrainAbout(sender: UIButton){
        if let topController = UIApplication.topViewController() {
            showOutbrainOnWebView(topController)
        }
    }
    
    
    static func startGlobalSpinner() {
        struct TokenContainer {
            static var token : Int = 0
        }
        
        _ = OBHelper.__once
        
        spinner.startAnimating()
    }
    
    static func stopGlobalSpinner() {
        spinner.stopAnimating()
    }
    
    fileprivate static func createSpinnerOnScreen() {
        let view = UIApplication.shared.keyWindow!
        spinner.color = UIColor(red: 242/255.0, green: 133/255.0, blue: 32/255.0, alpha: 1.0)
        spinner.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2);
        spinner.hidesWhenStopped = true;
        view.addSubview(spinner)
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
