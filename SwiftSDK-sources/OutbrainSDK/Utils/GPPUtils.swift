//
//  GPPUtils.swift
//  OutbrainSDK
//
//

import Foundation

let IABGPP_HDR_SectionsKey = "IABGPP_HDR_Sections"
let IABGPP_HDR_GppStringKey = "IABGPP_HDR_GppString"


class GPPUtils {
    
    static var userDefaults: UserDefaults = {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            IABGPP_HDR_SectionsKey: "",
            IABGPP_HDR_GppStringKey: ""
        ])
        return defaults
    }()
    
    static var gppSections: String? {
        return userDefaults.object(forKey: IABGPP_HDR_SectionsKey) as? String
    }
    
    static var gppString: String? {
        return userDefaults.object(forKey: IABGPP_HDR_GppStringKey) as? String
    }
    
}
