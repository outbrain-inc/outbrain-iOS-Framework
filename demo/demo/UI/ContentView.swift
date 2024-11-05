////
////  ContentView.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport


struct ContentView: View {
    
    @StateObject private var navigationViewModel: NavigationViewModel
    @State private var showCacheClearedAlert = false
    @State private var showGDPR = false
    
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
            .addTrailingActionBar(withTitle: "Outbrain SDK Demo", trailingActionName: "GDPR", trailingAction: {
                showGDPR = true
            })
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
            .sheet(isPresented: $showGDPR, content: {
                GdprRequestScreen { showGDPR = false }
            })
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ATTrackingManager.requestTrackingAuthorization { authStatus in
                        print("user authStatus is: \(authStatus)")
                        print("advertisingIdentifier: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
