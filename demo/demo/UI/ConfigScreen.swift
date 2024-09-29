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
    private var onClearCache: () -> Void
    
    init(
        navigationViewModel: NavigationViewModel,
        onSubmit: @escaping () -> Void,
        onClearCache: @escaping () -> Void
    ) {
        self._navigationViewModel = .init(wrappedValue: navigationViewModel)
        self.onSubmit = onSubmit
        self.onClearCache = onClearCache
    }
    
    
    var body: some View {
        configContent
            .navigationDestination(for: NavigationViewModel.Path.self) { path in
                switch path {
                    case .tableView: BridgeInTableView(
                        paramsViewModel: navigationViewModel.paramsViewModel,
                        readMore: false
                    )
                    .addNavigationBar(withTitle: "Bridge In Table View") {
                        navigationViewModel.popLast()
                    }
                        
                    case .collectionView: BridgeInCollectionView(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Bridge In Collection View") {
                                navigationViewModel.popLast()
                            }
                        
                    case .scrollView: BridgeInScrollView(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Bridge In Scroll View") {
                                navigationViewModel.popLast()
                            }
                        
                    case .swiftUI: BridgeInSwiftUI(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Bridge In SwiftUI") {
                                navigationViewModel.popLast()
                            }
                        
                    case .regularAndBridgeSwiftUI: RegularAndBridgeSwiftUI(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Regular and Bridge In SwiftUI") {
                                navigationViewModel.popLast()
                            }
                        
                    case .regularSwiftUI: RegularSDKSwiftUI(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Regular SDK (SwiftUI)") {
                                navigationViewModel.popLast()
                            }
                        
                    case .regularUIKit: RegularInUIKit(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Regular SDK (UIKit)") {
                                navigationViewModel.popLast()
                            }
                        
                    case .readMore: BridgeInTableView(paramsViewModel: navigationViewModel.paramsViewModel, readMore: true)
                            .addNavigationBar(withTitle: "Read More") {
                                navigationViewModel.popLast()
                            }
                        
                    case .useCases: UseCasesScreen(navigationViewModel: navigationViewModel)
                            .addNavigationBar(
                                withTitle: "Use Cases",
                                backAction: {
                                    navigationViewModel.popLast()
                                }
                            )
                        
                    case .twoWidgets: BridgeInScrollViewTwoWidgets(paramsViewModel: navigationViewModel.paramsViewModel)
                            .addNavigationBar(withTitle: "Two Widgets") {
                                navigationViewModel.popLast()
                            }
                }
            }
    }
    
    
    var configContent: some View {
        VStack {
            Text("SDK Version " + String(Outbrain.OB_SDK_VERSION))
            
            Toggle(isOn: $navigationViewModel.paramsViewModel.darkMode) {
                Text("Dark mode")
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Bridge widget ID")
                        .frame(height: 44)
                    
                    Text("Bridge Widget ID 2")
                        .frame(height: 44)
                    
                    Text("Regular Widget ID")
                        .frame(height: 44)
                }
                
                VStack {
                    TextField("", text: $navigationViewModel.paramsViewModel.bridgeWidgetId)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                    
                    
                    TextField("", text: $navigationViewModel.paramsViewModel.bridgeWidgetId2)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                    
                    TextField("", text: $navigationViewModel.paramsViewModel.regularWidgetId)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Article URL")
                
                TextField("", text: $navigationViewModel.paramsViewModel.articleURL)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: {
                onClearCache()
            }, label: {
                Text("Clear Cache")
            })
            .padding(.top, 16)
            
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
    ConfigScreen(
        navigationViewModel: .init(),
        onSubmit: { },
        onClearCache: { }
    )
}
