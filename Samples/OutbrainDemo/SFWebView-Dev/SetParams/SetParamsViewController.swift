//
//  SetParamsViewController.swift
//  SFWebView-Dev
//
//  Created by Shai Azulay on 19/02/2024.
//  Copyright © 2024 Outbrain inc. All rights reserved.
//

import UIKit

let GDPR_KEY  = "IABTCF_TCString"
let CCPA_KEY  = "IABUSPrivacy_String"
let GPP_KEY  = "IABGPP_HDR_GppString"
let GPP_SID_KEY  = "IABGPP_HDR_Sections"

class SetParamsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var gdprString: UITextField!
    @IBOutlet weak var ccpaString: UITextField!
    @IBOutlet weak var gppString: UITextField!
    @IBOutlet weak var gppSections: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gdprString.delegate = self
        ccpaString.delegate = self
        gppString.delegate = self
        gppSections.delegate = self
        
        gdprString.text = UserDefaults.standard.string(forKey:  GDPR_KEY)
        ccpaString.text = UserDefaults.standard.string(forKey:  CCPA_KEY)
        gppString.text = UserDefaults.standard.string(forKey:  GPP_KEY)
        gppSections.text = UserDefaults.standard.string(forKey:  GPP_SID_KEY)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if textField === gdprString {
            UserDefaults.standard.set(text, forKey: GDPR_KEY)
        } else if textField === ccpaString {
            UserDefaults.standard.set(text, forKey: CCPA_KEY)
        } else if textField === gppString {
            UserDefaults.standard.set(text, forKey: GPP_KEY)
        } else if textField === gppSections {
            UserDefaults.standard.set(text, forKey: GPP_SID_KEY)
        }
        
    }

}
