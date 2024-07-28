//
//  BridgeInSwiftUI.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import SwiftUI

struct BridgeInSwiftUI: View {
    
    let params: ParamsViewModel
    
    @StateObject
    private var viewModel: OutbrainWidgetViewModel
    @State private var scrollFrame: CGRect = .zero
    
    
    init(params: ParamsViewModel) {
        self.params = params
        self._viewModel = .init(wrappedValue: OutbrainWidgetViewModel(paramsViewModel: params))
    }
    
    var body: some View {
        GeometryReader { geometry -> AnyView in
            let frame = geometry.frame(in: CoordinateSpace.local)
            
            AnyView(
                ScrollView {
                    ZStack {
                        LazyVStack {
                            ListItem(color: .purple)
                            ListItem(color: .green)
                            ListItem(color: .pink)
                            ListItem(color: .cyan)
                            
                            OutbrainWidgetView(
                                viewModel: viewModel,
                                scrollViewFrame: frame,
                                scrollFrame: $scrollFrame
                            )
                            .frame(height: viewModel.widgetHeight)
                        }
                        
                        
                        GeometryReader { proxy in
                            let size = proxy.frame(in: .named("scroll")).size
                            let y = proxy.frame(in: .named("scroll")).minY
                            
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: .init(origin: .init(x: 0, y: y), size: size)
                            )
                        }
                    }
                }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollFrame = value
                    }
            )
        }
        .navigationTitle("Outbrain issue demo")
    }
}

#Preview {
    BridgeInSwiftUI(params: .init())
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}



struct ScrollSizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
