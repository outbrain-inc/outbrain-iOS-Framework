//
//  OutbrainWidgetView.swift
//  OutbrainSwiftUI
//
//  Created by Mikhail Vasilev on 22.07.24.
//

import OutbrainSDK
import SwiftUI


struct OutbrainWidgetView: UIViewRepresentable {

    @ObservedObject
    var viewModel: OutbrainWidgetViewModel
    let scrollViewFrame: CGRect
    
    @Binding var scrollFrame: CGRect
    

    final class Coordinator: NSObject, SFWidgetDelegate {

        private let viewModel: OutbrainWidgetViewModel

        init(viewModel: OutbrainWidgetViewModel) {
            self.viewModel = viewModel
        }

        // MARK: - SFWidgetDelegate

        func onRecClick(_ url: URL) {}

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
                url: "https://mobile-demo.outbrain.com",
                widgetId: "MB_1",
                widgetIndex: 0,
                installationKey: "NANOWDGT01",
                userId: nil,
                darkMode: false,
                isSwiftUI: false
            )
        
        return viewModel.widget
    }
    
    private func didScroll() {
        let scrollView = UIScrollView()
        scrollView.frame = scrollViewFrame
        scrollView.contentSize = scrollFrame.size
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollFrame.origin.y)
        viewModel.widget.scrollViewDidScroll(scrollView)
    }

    func updateUIView(_ uiView: SFWidget, context: Context) {
        didScroll()
    }
}

