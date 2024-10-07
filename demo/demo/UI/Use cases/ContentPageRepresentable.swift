//
//  Untitled.swift
//  demo
//
//  Created by Leonid Lemesev on 07/10/2024.
//

import SwiftUI


struct ContentPageRepresentable<T: UIKitContentPage>: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = T
    let navigationViewModel: NavigationViewModel
    let params: [String: Bool]?
    
    init(
        navigationViewModel: NavigationViewModel,
        params: [String : Bool]? = nil
    ) {
        self.navigationViewModel = navigationViewModel
        self.params = params
    }
    
    
    func makeUIViewController(context: Context) -> T {
        // Instantiate your UIKit view controller here
        let articleVC = T.init(
            navigationViewModel: navigationViewModel,
            params: params
        )
        
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}
