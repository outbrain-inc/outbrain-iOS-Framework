//
//  RegularSDK.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI
import OutbrainSDK
import SafariServices



struct RegularInUIKit: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ScrollViewVC
    
    let paramsViewModel: ParamsViewModel
    
    func makeUIViewController(context: Context) -> ScrollViewVC {
        // Instantiate your UIKit view controller here
        let articleVC = ScrollViewVC(
            paramsViewModel: paramsViewModel,
            isRegular: true
        )
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: ScrollViewVC, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
