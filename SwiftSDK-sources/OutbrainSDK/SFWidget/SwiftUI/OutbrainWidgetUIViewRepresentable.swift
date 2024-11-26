//
//  OutbrainWidgetUIViewRepresentable.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 21/11/2024.
//


import SwiftUI


struct OutbrainWidgetUIViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var viewModel: OutbrainWidgetViewModel
    let config: SFWidgetConfig
    
    
    init(
        viewModel: OutbrainWidgetViewModel,
        config: SFWidgetConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    
    final class Coordinator: NSObject, SFWidgetDelegate {
        
        private let viewModel: OutbrainWidgetViewModel
        
        
        init(viewModel: OutbrainWidgetViewModel) {
            self.viewModel = viewModel
            
            if viewModel.onWidgetEvent != nil {
                viewModel.widget.enableEvents()
            }
        }
        
        
        // MARK: - SFWidgetDelegate
        func onRecClick(_ url: URL) {
            viewModel.clickedUrl = url
        }
        
        
        func onOrganicRecClick(_ url: URL) {
            viewModel.onOrganicRecClick?(url)
        }
        
        
        func didChangeHeight(_ newHeight: CGFloat) {
            viewModel.widgetHeight = newHeight
        }
        
        
        func widgetEvent(_ eventName: String, additionalData: [String : Any]) {
            viewModel.onWidgetEvent?(eventName, additionalData)
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    
    func makeUIView(context: Context) -> SFWidget {
        viewModel.widget
            .configure(
                with: context.coordinator,
                url: config.url,
                widgetId: config.widgetId,
                widgetIndex: config.widgetIndex,
                installationKey: "NANOWDGT01",
                userId: config.userId,
                darkMode: config.darkMode
            )
        
        viewModel.widget.extId = config.extId
        viewModel.widget.extSecondaryId = config.extSecondaryId
        viewModel.widget.OBPubImp = config.OBPubImp
        
        return viewModel.widget
    }
    
    
    func updateUIView(_ uiView: SFWidget, context: Context) { }
}
