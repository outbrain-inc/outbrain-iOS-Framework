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
        "Read More",
        "Two widgets on the same page",
        "Smart Logic"
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
                        case 6:
                            navigationViewModel.push(.twoWidgets)
                        case 7:
                            navigationViewModel.push(.smartLogic)
                        default: return
                    }
                }) {
                    Text(element)
                }
            }
        }
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
