////
////  ContentView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var navigationViewModel: NavigationViewModel
    
    init() {
        self._navigationViewModel = .init(wrappedValue: .init())
    }
    
    var body: some View {
        NavigationStack(path: $navigationViewModel.paths) {
            ConfigScreen(navigationViewModel: navigationViewModel) {
                navigationViewModel.push(.useCases)
            } onClearCache: {
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Outbrain SDK Demo")
                }
            }
            .toolbarBackground(Color.outbrainOrange, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
