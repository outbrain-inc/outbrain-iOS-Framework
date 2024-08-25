//
//  OBSafariView.swift
//  demo
//
//  Created by Leonid Lemesev on 29/07/2024.
//

import Foundation
import SwiftUI
import SafariServices


struct OBSafariView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<OBSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<OBSafariView>
    ) {
        
    }
}
