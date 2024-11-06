//
//  OutbrainWidgetView.swift
//  OutbrainSwiftUI
//
//  Created by Mikhail Vasilev on 22.07.24.
//

import OutbrainSDK
import SwiftUI



struct OutbrainWidgetView: UIViewRepresentable {

    @ObservedObject var viewModel: OutbrainWidgetViewModel
    private let twoWidgets: Bool
    private let widgetIndex: Int
    private let widgetId: String
    let isRegular: Bool
    let isOrganic: Bool
    let organicUrl: String?
    
    
    init(
        viewModel: OutbrainWidgetViewModel,
        isRegular: Bool = false,
        twoWidgets: Bool = false,
        isOrganic: Bool = false,
        widgetIndex: Int = 0,
        organicUrl: String? = nil
    ) {
        self.viewModel = viewModel
        self.isRegular = isRegular
        self.twoWidgets = twoWidgets
        self.isOrganic = isOrganic
        self.widgetIndex = widgetIndex
        self.organicUrl = organicUrl
        
        if twoWidgets && widgetIndex == 0 {
            self.widgetId = viewModel.paramsViewModel.bridgeWidgetId2
        } else {
            self.widgetId = viewModel.paramsViewModel.bridgeWidgetId
        }
    }
    

    final class Coordinator: NSObject, SFWidgetDelegate {

        private let viewModel: OutbrainWidgetViewModel
        private let twoWidgets: Bool
        private let isRegular: Bool
        private let isOrganic: Bool
        

        init(
            viewModel: OutbrainWidgetViewModel,
            twoWidgets: Bool,
            isRegular: Bool,
            isOrganic: Bool
        ) {
            self.viewModel = viewModel
            self.twoWidgets = twoWidgets
            self.isRegular = isRegular
            self.isOrganic = isOrganic
        }

        // MARK: - SFWidgetDelegate
        func onRecClick(_ url: URL) {
            viewModel.clickedUrl = url
        }
        
        
        func onOrganicRecClick(_ url: URL) {
            DispatchQueue.main.async { [weak self] in
                if self?.isRegular == true {
                    self?.viewModel.navigationViewModel.push(.regularAndBridgeSwiftUI)
                } else if self?.twoWidgets == true {
                    self?.viewModel.navigationViewModel.push(.twoWidgetsSwiftUI)
                } else if self?.isOrganic == true {
                    self?.viewModel.navigationViewModel.push(.organic(url.absoluteString))
                } else {
                    self?.viewModel.navigationViewModel.push(.swiftUI)
                }
            }
        }

        func didChangeHeight(_ newHeight: CGFloat) {
            viewModel.widgetHeight = newHeight
        }
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator(
            viewModel: viewModel,
            twoWidgets: twoWidgets,
            isRegular: isRegular,
            isOrganic: isOrganic
        )
    }

    
    func makeUIView(context: Context) -> SFWidget {
        viewModel.widget
            .configure(
                with: context.coordinator,
                url: organicUrl ?? viewModel.paramsViewModel.articleURL,
                widgetId: viewModel.paramsViewModel.bridgeWidgetId,
                widgetIndex: widgetIndex,
                installationKey: "NANOWDGT01",
                userId: nil,
                darkMode: viewModel.paramsViewModel.darkMode
            )
        
        return viewModel.widget
    }
    
    
    func updateUIView(_ uiView: SFWidget, context: Context) { }
}

