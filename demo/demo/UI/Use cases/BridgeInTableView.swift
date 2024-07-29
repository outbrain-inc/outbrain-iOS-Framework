//
//  BridgeInTableView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI


struct BridgeInTableView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = TableVC
    
    let paramsViewModel: ParamsViewModel
    let readMore: Bool
    
    func makeUIViewController(context: Context) -> TableVC {
        // Instantiate your UIKit view controller here
        let articleVC = TableVC(paramsViewModel: paramsViewModel, readMore: readMore)
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: TableVC, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
