//
//  NavigationBarViewModifier.swift
//  demo
//
//  Created by Leonid Lemesev on 25/07/2024.
//

import Foundation
import SwiftUI


struct NavigationBarViewModifier: ViewModifier {
    let title: String
    let backAction: (() -> Void)?
    
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if backAction != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "arrow.backward")
                            .onTapGesture {
                                backAction?()
                            }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(title)
                }
            }
            .toolbarBackground(Color.outbrainOrange, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}


extension View {
    func addNavigationBar(
        withTitle title: String,
        backAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            NavigationBarViewModifier(
                title: title,
                backAction: backAction
            )
        )
    }
}
