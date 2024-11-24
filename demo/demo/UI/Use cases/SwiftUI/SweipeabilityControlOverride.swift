//
//  SweipeabilityControlOverride.swift
//  demo
//
//  Created by Leonid Lemesev on 24/11/2024.
//

import SwiftUI
import OutbrainSDK


struct SweipeabilityControlOverride: View {
    
    private let navigationViewModel: NavigationViewModel
    
    @StateObject
    private var viewModel: OutbrainWidgetViewModel
    
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self._viewModel = .init(wrappedValue: OutbrainWidgetViewModel(navigationViewModel: navigationViewModel, paramsViewModel: paramsViewModel))
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                Image("articleImage", bundle: Bundle.main)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                
                Text("The Guardian")
                    .padding()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 80.0)
                    .background(.blue)
                    .foregroundColor(.white)
                
                Text("Suarez: Messi Was Born Great, Ronaldo Made Himself Great")
                    .font(.system(size: 24))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 0))
                
                ArticleBody()
                ArticleBody()
                
                OutbrainWidgetView(viewModel: viewModel)
                    .frame(height: viewModel.widgetHeight)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Determine the swipe direction
                    if value.translation.width > 0 {
                        // Right swipe
                        navigationViewModel.popLast()
                    } else if value.translation.width < 0 {
                        // Left swipe
                        navigationViewModel.push(.swipeabilityControlSwiftUI)
                    }
                }
        )
        .fullScreenCover(isPresented: .init(
            get: { viewModel.clickedUrl != nil },
            set: { value in
                if !value {
                    viewModel.clickedUrl = nil
                }
            }
        )) {
            OBSafariView(url: $viewModel.clickedUrl.wrappedValue!)
                .ignoresSafeArea(edges: .all)
        }
    }
}
