//
//  BridgeInCollectionView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI


struct BridgeInCollectionView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CollectionVC
    
    let paramsViewModel: ParamsViewModel
    
    func makeUIViewController(context: Context) -> CollectionVC {
        // Instantiate your UIKit view controller here
        let articleVC = CollectionVC(
            paramsViewModel: paramsViewModel
        )
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: CollectionVC, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
