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
        "Bridge in ScrollView",
        "Bridge in SwiftUI",
        "Regular + Bridge (SwiftUI)",
        "Regular SDK (SwiftUI)",
        "Regular SDK (UIKit)",
        "Read More",
        "Two widgets on the same page",
        "Two widgets (SwiftUI)",
        "Organic URL Referrer",
        "Static Widget (No scroll)",
        "Swipeability Control (UIKit)",
        "Swipeability Control (SwiftUI)"
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
                            navigationViewModel.push(.scrollView)
                        case 3:
                            navigationViewModel.push(.swiftUI)
                        case 4:
                            navigationViewModel.push(.regularAndBridgeSwiftUI)
                        case 5:
                            navigationViewModel.push(.regularSwiftUI)
                        case 6:
                            navigationViewModel.push(.regularUIKit)
                        case 7:
                            navigationViewModel.push(.readMore)
                        case 8:
                            navigationViewModel.push(.twoWidgets)
                        case 9:
                            navigationViewModel.push(.twoWidgetsSwiftUI)
                        case 10:
                            navigationViewModel.push(.organic(nil))
                        case 11:
                            navigationViewModel.push(.staticWidget)
                        case 12:
                            navigationViewModel.push(.swipeabilityControl)
                        case 13:
                            navigationViewModel.push(.swipeabilityControlSwiftUI)
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

extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}
