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
    

    final class Coordinator: NSObject, SFWidgetDelegate {

        private let viewModel: OutbrainWidgetViewModel

        init(viewModel: OutbrainWidgetViewModel) {
            self.viewModel = viewModel
        }

        // MARK: - SFWidgetDelegate
        func onRecClick(_ url: URL) {
            viewModel.clickedUrl = url
        }

        func didChangeHeight(_ newHeight: CGFloat) {
            self.viewModel.widgetHeight = newHeight
        }
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    
    func makeUIView(context: Context) -> SFWidget {
        viewModel.widget
            .configure(
                with: context.coordinator,
                url: viewModel.paramsViewModel.articleURL,
                widgetId: viewModel.paramsViewModel.bridgeWidgetId,
                widgetIndex: 0,
                installationKey: "NANOWDGT01",
                userId: nil,
                darkMode: viewModel.paramsViewModel.darkMode
            )
        
        return viewModel.widget
    }
    
    
    func updateUIView(_ uiView: SFWidget, context: Context) { }
}

