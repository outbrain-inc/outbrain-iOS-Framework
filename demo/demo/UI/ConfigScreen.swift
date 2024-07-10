//
//  ConfigScreen.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI
import OutbrainSDK

struct ConfigScreen: View {
    
    @StateObject var navigationViewModel: NavigationViewModel
    private var onSubmit: () -> Void
    
    init(
        navigationViewModel: NavigationViewModel,
        onSubmit: @escaping () -> Void
    ) {
        self._navigationViewModel = .init(wrappedValue: navigationViewModel)
        self.onSubmit = onSubmit
    }
    
    
    var body: some View {
        useCasesContent
            .navigationDestination(for: NavigationViewModel.Path.self) { path in
                switch path {
                    case .tableView: BridgeInTableView(paramsViewModel: navigationViewModel.paramsViewModel)
                    case .collectionView: BridgeInCollectionView(paramsViewModel: navigationViewModel.paramsViewModel)
                    case .swiftUI: Text("SwiftUI")
                    case .scrollView: Text("Scroll View")
                    case .regular: Text("Regular")
                    case .readMore: Text("Read More")
                    case .useCases: UseCasesScreen(navigationViewModel: navigationViewModel)
                }
            }
    }
    
    var useCasesContent: some View {
        VStack {
            Text("SDK Version " + String(OB_SDK_VERSION))
            
            Toggle(isOn: $navigationViewModel.paramsViewModel.darkMode) {
                Text("Dark mode")
            }
            
            HStack {
                Text("Widget ID")
                    .padding(.trailing, 16)
                TextField("", text: $navigationViewModel.paramsViewModel.widgetId)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Article URL")
                    .padding(.trailing, 16)
                TextField("", text: $navigationViewModel.paramsViewModel.articleURL)
                    .textFieldStyle(.roundedBorder)
            }
            
            Spacer()
            
            Button(action: {
                onSubmit()
            }, label: {
                Text("Submit")
            })
        }
        .padding()
    }
}

#Preview {
    ConfigScreen(navigationViewModel: .init()) { }
}
