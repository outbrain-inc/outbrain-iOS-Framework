////
////  ContentView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var navigationViewModel: NavigationViewModel
    @State private var showCacheClearedAlert = false
    
    init() {
        self._navigationViewModel = .init(wrappedValue: .init())
    }
    
    var body: some View {
        NavigationStack(path: $navigationViewModel.paths) {
            ConfigScreen(navigationViewModel: navigationViewModel) {
                navigationViewModel.push(.useCases)
            } onClearCache: {
                navigationViewModel.clearCache {
                    showCacheClearedAlert = true
                }
            }
            .addNavigationBar(withTitle: "Outbrain SDK Demo")
            .alert(isPresented: $showCacheClearedAlert) {
                Alert(
                    title: Text("Cache Cleared"),
                    message: Text("All cached data has been successfully cleared."),
                    dismissButton: .default(
                        Text("Ok"),
                        action: {
                            showCacheClearedAlert = false
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
