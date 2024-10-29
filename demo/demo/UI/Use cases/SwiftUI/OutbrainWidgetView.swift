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
    let organicUrl: String?
    
    
    init(
        viewModel: OutbrainWidgetViewModel,
        isRegular: Bool = false,
        twoWidgets: Bool = false,
        widgetIndex: Int = 0,
        organicUrl: String? = nil
    ) {
        self.viewModel = viewModel
        self.isRegular = isRegular
        self.twoWidgets = twoWidgets
        self.widgetIndex = widgetIndex
        self.organicUrl = organicUrl
        
        if twoWidgets && widgetIndex == 0 {
            self.widgetId = viewModel.navigationViewModel.paramsViewModel.bridgeWidgetId2
        } else {
            self.widgetId = viewModel.navigationViewModel.paramsViewModel.bridgeWidgetId
        }
    }
    

    final class Coordinator: NSObject, SFWidgetDelegate {

        private let viewModel: OutbrainWidgetViewModel
        private let twoWidgets: Bool
        private let isRegular: Bool

        init(
            viewModel: OutbrainWidgetViewModel,
            twoWidgets: Bool,
            isRegular: Bool
        ) {
            self.viewModel = viewModel
            self.twoWidgets = twoWidgets
            self.isRegular = isRegular
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
            isRegular: isRegular
        )
    }

    
    func makeUIView(context: Context) -> SFWidget {
        viewModel.widget
            .configure(
                with: context.coordinator,
                url: organicUrl ?? viewModel.navigationViewModel.paramsViewModel.articleURL,
                widgetId: viewModel.navigationViewModel.paramsViewModel.bridgeWidgetId,
                widgetIndex: widgetIndex,
                installationKey: "NANOWDGT01",
                userId: nil,
                darkMode: viewModel.navigationViewModel.paramsViewModel.darkMode
            )
        
        return viewModel.widget
    }
    
    
    func updateUIView(_ uiView: SFWidget, context: Context) { }
}

