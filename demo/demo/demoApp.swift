//
//  demoApp.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI
import OutbrainSDK

@main
struct demoApp: App {
    
    init() {
        Outbrain.initializeOutbrain(withPartnerKey: "iOSSampleApp2014")
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
