//
//  SFWidgetObservable.swift
//  SwiftUI-Bridge
//
//  Created by Oded Regev on 02/08/2022.
//  Copyright © 2022 Outbrain inc. All rights reserved.
//

import Foundation
import SafariServices
import SwiftUI
import OutbrainSDK

// Our observable object class
class SFWidgetObservable: ObservableObject {
    @Published var showSafari:Bool = false
    @Published var url:URL?
    @Published var widgetHeight:CGFloat = 800.0
}

struct SFWidgetWrapper: UIViewRepresentable {
    @EnvironmentObject var sfWidgetObservable: SFWidgetObservable
    
    let widgetId:String
    let baseURL:String
    let installationKey:String
    let myCustomDelegate = CustomSFWidgetDelegate()
    
    func updateUIView(_ uiView: SFWidget, context: Context) {
        uiView.configure(with: myCustomDelegate, url: baseURL, widgetId: widgetId, widgetIndex: 0, installationKey: installationKey, userId: nil, darkMode: false, isSwiftUI: true);
            
                         
        myCustomDelegate.sfWidgetObservable = sfWidgetObservable
    }
    
    func makeUIView(context: Context) -> SFWidget {
        SFWidget()
    }
}


struct OBSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<OBSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<OBSafariView>) {

    }
}

