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
    
    @State
    var paramsViewModel: ParamsViewModel = { .init() }()
    
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
                    case .tableView: ContentPageRepresentable<TableVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: .init(),
                        params: ["readMore": false]
                    )
                    .addNavigationBar(withTitle: "Bridge In Table View") {
                        navigationViewModel.popLast()
                    }
                        
                    case .collectionView: ContentPageRepresentable<CollectionVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Bridge In Collection View") {
                        navigationViewModel.popLast()
                    }
                        
                    case .scrollView: ContentPageRepresentable<ScrollViewVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Bridge In Scroll View") {
                        navigationViewModel.popLast()
                    }
                        
                    case .swiftUI: BridgeInSwiftUI(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Bridge In SwiftUI") {
                        navigationViewModel.popLast()
                    }
                        
                    case .regularAndBridgeSwiftUI: RegularAndBridgeSwiftUI(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Regular and Bridge In SwiftUI") {
                        navigationViewModel.popLast()
                    }
                        
                    case .regularSwiftUI: RegularSDKSwiftUI(
                        paramsViewModel: paramsViewModel,
                        navigationViewModel: navigationViewModel
                    )
                            .addNavigationBar(withTitle: "Regular SDK (SwiftUI)") {
                                navigationViewModel.popLast()
                            }
                        
                    case .regularUIKit: ContentPageRepresentable<ScrollViewVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel,
                        params: ["isRegular": true]
                    )
                    .addNavigationBar(withTitle: "Regular SDK (UIKit)") {
                        navigationViewModel.popLast()
                    }
                        
                    case .readMore: ContentPageRepresentable<TableVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel,
                        params: ["readMore": true]
                    )
                    .addNavigationBar(withTitle: "Read More") {
                        navigationViewModel.popLast()
                    }
                        
                    case .useCases: UseCasesScreen(navigationViewModel: navigationViewModel)
                            .addNavigationBar(withTitle: "Use Cases") {
                                navigationViewModel.popLast()
                            }
                        
                    case .twoWidgets: ContentPageRepresentable<ScrollViewTwoWidgets>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Two Widgets") {
                        navigationViewModel.popLast()
                    }
                        
                    case .twoWidgetsSwiftUI: TwoWidgetsSwiftuI(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Two Widgets (SwiftUI)") {
                        navigationViewModel.popLast()
                    }
                        
                    case .organic(let url): OrganicReferrerUseCase(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel,
                        organicUrl: url
                    )
                    .addNavigationBar(withTitle: "Organic Referrer") {
                        navigationViewModel.popLast()
                    }
                        
                    case .staticWidget: StaticWidgetUseCase(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel
                    )
                    .addNavigationBar(withTitle: "Static Widget") {
                        navigationViewModel.popLast()
                    }
                        
                    case .swipeabilityControl: ContentPageRepresentable<ScrollViewVC>(
                        navigationViewModel: navigationViewModel,
                        paramsViewModel: paramsViewModel,
                        params: ["horizontalSwipes": true]
                    )
                    .addNavigationBar(withTitle: "Swipeability Control") {
                        navigationViewModel.popLast()
                    }
                        
                    case .swipeabilityControlSwiftUI:
                        SweipeabilityControlOverride(
                            navigationViewModel: navigationViewModel,
                            paramsViewModel: paramsViewModel
                        )
                        .addNavigationBar(withTitle: "Swipeability Control SwiftUI") {
                            navigationViewModel.popLast()
                        }
                }
            }
    }
    
    
    var configContent: some View {
        VStack {
            Text("SDK Version " + String(Outbrain.OB_SDK_VERSION))
            
            
            Toggle(isOn: $paramsViewModel.displayTest) {
                Text("Display test")
            }
            .onChange(of: paramsViewModel.displayTest) { value in
                Outbrain.testDisplay(value)
            }
            
            Toggle(isOn: $paramsViewModel.darkMode) {
                Text("Dark mode")
            }
            
            Toggle(isOn: $paramsViewModel.fakeConsent) {
                Text("Send Fake GDPR Consent")
            }
            .onChange(of: paramsViewModel.fakeConsent) { oldValue in
                if paramsViewModel.fakeConsent {
                    UserDefaults.standard.set("CQH36sAQH36sAAHABBENBOFsAP_gAABAAAqIJ1NF7C7fbXFicX53YPsEcY1fxdAKosQwBAAJg2wByBJQsIwElmAxNAXgBiAKGAIAIGRBAQJlCADABUAAYAAAIyDMIAAQARAIIqAEgAARQEAICABjGQkAEAAYgGIAAEAAmQoEABqoUEBAgAAgIEAAIAAhAICBAgGIACEgQAAYAQAIwmgAAQAAIAAAEAAEAFAMEEBAAAEAAIACBAAMIAABAAAAMUgAwABBUQdABgACCohCADAAEFRCUAGAAIKiBIAMAAQVELQAYAAgqIAA.f_wAAAgAAAAA", forKey: "IABTCF_TCString")
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.removeObject(forKey: "IABTCF_TCString")
                }
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
                    TextField("", text: $paramsViewModel.bridgeWidgetId)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                    
                    
                    TextField("", text: $paramsViewModel.bridgeWidgetId2)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                    
                    TextField("", text: $paramsViewModel.regularWidgetId)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Article URL")
                
                TextField("", text: $paramsViewModel.articleURL)
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
