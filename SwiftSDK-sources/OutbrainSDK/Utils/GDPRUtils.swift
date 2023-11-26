//
//  GDPRUtils.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 20/06/2023.
//

import Foundation

let IAB_US_Privacy_String = "IABUSPrivacy_String"
let IABConsent_SubjectToGDPRKey = "IABConsent_SubjectToGDPR"
let IABConsent_V1_ConsentStringKey = "IABConsent_ConsentString"
let IABConsent_V2_ConsentStringKey = "IABTCF_TCString"
let IABConsent_ParsedVendorConsentsKey = "IABConsent_ParsedVendorConsents"
let IABConsent_ParsedPurposeConsentsKey = "IABConsent_ParsedPurposeConsents"
let IABConsent_CMPPresentKey = "IABConsent_CMPPresent"

enum SubjectToGDPR: Int {
    case unknown = -1
    case no = 0
    case yes = 1
}


class GDPRUtils {
    
    static var userDefaults: UserDefaults = {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            IABConsent_V1_ConsentStringKey: "",
            IABConsent_V2_ConsentStringKey: "",
            IAB_US_Privacy_String: "",
            IABConsent_CMPPresentKey: NSNumber(value: false)
        ])
        return defaults
    }()
    
    static var gdprV1ConsentString: String? {
        return userDefaults.object(forKey: IABConsent_V1_ConsentStringKey) as? String
    }
    
    static var gdprV2ConsentString: String? {
        return userDefaults.object(forKey: IABConsent_V2_ConsentStringKey) as? String
    }
    
    static var ccpaPrivacyString: String? {
        return userDefaults.object(forKey: IAB_US_Privacy_String) as? String
    }
    
    static var subjectToGDPR: SubjectToGDPR {
        if let subjectToGDPRAsString = self.userDefaults.object(forKey: IABConsent_SubjectToGDPRKey) as? String {
            if subjectToGDPRAsString == "0" {
                return .no
            } else if subjectToGDPRAsString == "1" {
                return .yes
            } else {
                return .unknown
            }
        } else {
            return .unknown
        }
    }
}
