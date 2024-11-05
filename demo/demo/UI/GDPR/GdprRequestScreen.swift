//
//  GdprRequestScreen.swift
//  demo
//
//  Created by Leonid Lemesev on 05/11/2024.
//


import SwiftUI


struct GdprRequestScreen: View {
    
    let onDismiss: (() -> Void)
    
    var body: some View {
        ConsentWebView(url: URL(string: "https://demofiles.smaato.com/cmp/index.html")!) { consent in
            onDismiss()
        }
    }
}




