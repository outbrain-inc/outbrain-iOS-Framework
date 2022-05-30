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
    static let smartFeedWidgetID = "MB_1"
    static let regularWidgetID = "MB_2"
    static let smartLogicWidgetID = "MB_3"
    static var baseURL = "https://mobile-demo.outbrain.com"
    static var installationKey = "NANOWDGT01"
}


class ViewController: UIViewController {

    @IBOutlet weak var customWidgetIdTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SFWebView Demo App"
    
        
        customWidgetIdTextField.delegate = self
        
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                ATTrackingManager.requestTrackingAuthorization { authStatus in
                    print("user authStatus is: \(authStatus)")
                    print("advertisingIdentifier: \(ASIdentifierManager.shared().advertisingIdentifier)")
                }
            })
        }
        
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        customWidgetIdTextField.isEnabled = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard var vc = segue.destination as? OBViewController else { return }
        vc.widgetId = getWidgetId()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            // value for first index selected here
            customWidgetIdTextField.isEnabled = true
        } else {
            customWidgetIdTextField.isEnabled = false
        }
    }
    
    func getWidgetId() -> String {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return OBConf.smartFeedWidgetID
        case 1:
            return OBConf.regularWidgetID
        case 2:
            return OBConf.smartLogicWidgetID
        case 3:
            return customWidgetIdTextField.text ?? ""
        default:
            return ""
        }
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
        
        alert.addTextField { (textField) in
            textField.placeholder = "Page URL"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if var urlString = alert!.textFields?[0].text {
                print("url: \(urlString)")
                
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
                
                let successAlert = UIAlertController(title: "Success", message: "Smartfeed will load with new url (\(urlString))", preferredStyle: .alert)
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

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
