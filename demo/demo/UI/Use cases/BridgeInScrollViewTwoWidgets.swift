//
//  BridgeInScrollViewTwoWidgets.swift
//  demo
//
//  Created by Leonid Lemesev on 30/07/2024.
//

import Foundation
import SwiftUI

struct BridgeInScrollViewTwoWidgets: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ScrollViewTwoWidgets
    
    let paramsViewModel: ParamsViewModel
    
    func makeUIViewController(context: Context) -> ScrollViewTwoWidgets {
        // Instantiate your UIKit view controller here
        let articleVC = ScrollViewTwoWidgets(paramsViewModel: paramsViewModel)
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: ScrollViewTwoWidgets, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
