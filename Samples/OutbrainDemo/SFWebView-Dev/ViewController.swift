//
//  ViewController.swift
//  SFWebView-Dev
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import AdSupport

struct OBConf {
    static var widgetID = "MB_1"
    static var baseURL = "https://mobile-demo.outbrain.com"
    static var installationKey = "NANOWDGT01"
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SFWebView Demo App"
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { authStatus in
                print("user authStatus is: \(authStatus)")
                print("advertisingIdentifier: \(ASIdentifierManager.shared().advertisingIdentifier)")
            }
        }
        performSegue(withIdentifier: "showCollectionVC", sender: nil)
    }
}

extension ViewController {
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Why are you shaking me?")
            self.showAlert()
        }
    }
    
    func showAlert() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Edit Fields", message: "Please edit the fields below", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Widget ID"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Page URL"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let widgetID = alert?.textFields?[0].text, var urlString = alert!.textFields?[1].text {
                print("widgetID: \(widgetID)")
                print("url: \(urlString)")
                
                OBConf.widgetID = widgetID;
                
                if (urlString.starts(with: "www")) {
                    urlString = "https://" + urlString
                }
                if (self.verifyUrl(urlString: urlString)) {
                    OBConf.baseURL = urlString
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: "URL is not valid (\(urlString))", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                let successAlert = UIAlertController(title: "Success", message: "Smartfeed will load with new fields (\(widgetID)) (\(urlString))", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(successAlert, animated: true, completion: {
                    
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}

