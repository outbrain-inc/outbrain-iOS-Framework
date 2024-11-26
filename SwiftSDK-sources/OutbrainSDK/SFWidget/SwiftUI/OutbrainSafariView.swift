//
//  OBSafariView.swift
//  demo
//
//  Created by Leonid Lemesev on 29/07/2024.
//

import Foundation
import SwiftUI
import SafariServices


public struct OutbrainSafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    
    public init(url: URL) {
        self.url = url
    }
    
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<OutbrainSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    
    public func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<OutbrainSafariView>
    ) { }
}
