//
//  BridgeInTableView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI


struct BridgeInTableView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ArticleTableViewController
    
    let paramsViewModel: ParamsViewModel
    
    func makeUIViewController(context: Context) -> ArticleTableViewController {
        // Instantiate your UIKit view controller here
        let articleVC = ArticleTableViewController(paramsViewModel: paramsViewModel)
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: ArticleTableViewController, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
