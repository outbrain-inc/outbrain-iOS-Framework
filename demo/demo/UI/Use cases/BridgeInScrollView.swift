//
//  BridgeInScrollView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI

struct BridgeInScrollView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ScrollViewVC
    
    let paramsViewModel: ParamsViewModel
    let isSmartLogic: Bool
    
    func makeUIViewController(context: Context) -> ScrollViewVC {
        // Instantiate your UIKit view controller here
        let articleVC = ScrollViewVC(
            paramsViewModel: paramsViewModel,
            isSmartLogic: isSmartLogic
        )
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: ScrollViewVC, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
