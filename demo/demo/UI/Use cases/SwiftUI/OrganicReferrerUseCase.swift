//
//  OrganicReferrerUseCase.swift
//  demo
//
//  Created by Leonid Lemesev on 29/10/2024.
//

import SwiftUI
import OutbrainSDK



struct OrganicReferrerUseCase: View {
    
    private let navigationViewModel: NavigationViewModel
    private let organicUrl: String?
    
    @StateObject
    private var viewModel: OutbrainWidgetViewModel
    
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel,
        organicUrl: String?
    ) {
        self.navigationViewModel = navigationViewModel
        self.organicUrl = organicUrl
        self._viewModel = .init(wrappedValue: OutbrainWidgetViewModel(navigationViewModel: navigationViewModel, paramsViewModel: paramsViewModel))
    }
    
    var body: some View {
        ScrollView {
            ZStack {
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
                    
                    OutbrainWidgetView(
                        viewModel: viewModel,
                        isOrganic: true,
                        organicUrl: organicUrl
                    )
                        .frame(height: viewModel.widgetHeight)
                }
                
            }
        }
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
