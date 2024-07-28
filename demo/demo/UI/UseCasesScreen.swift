//
//  UseCasesScreen.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI

struct UseCasesScreen: View {
    
    @StateObject private var navigationViewModel: NavigationViewModel
    
    private var useCases = [
        "Bridge in TableView",
        "Bridge in CollectionView",
        "Bridge in SwiftUI",
        "Bridge in ScrollView",
        "Regular SDK",
        "Read More"
    ]
    
    
    init(navigationViewModel: NavigationViewModel) {
        self._navigationViewModel = .init(wrappedValue: navigationViewModel)
    }
    
    
    var body: some View {
        List {
            ForEach(Array(useCases.enumerated()), id: \.offset) { index, element in
                Button(action: {
                    switch index {
                        case 0:
                            navigationViewModel.push(.tableView)
                        case 1:
                            navigationViewModel.push(.collectionView)
                        case 2:
                            navigationViewModel.push(.swiftUI)
                        case 3:
                            navigationViewModel.push(.scrollView)
                        case 4:
                            navigationViewModel.push(.regular)
                        case 5:
                            navigationViewModel.push(.readMore)
                        default: return
                    }
                }) {
                    Text(element)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "arrow.backward")
                    .onTapGesture {
                        navigationViewModel.popLast()
                    }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Use cases")
            }
        }
        .toolbarBackground(Color.outbrainOrange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    UseCasesScreen(navigationViewModel: .init())
}

extension String: Identifiable {
    public var id: String {
        self
    }
}
