//
//  StaticWidgetUseCase.swift
//  demo
//
//  Created by Leonid Lemesev on 05/11/2024.
//

import SwiftUI
import OutbrainSDK


struct StaticWidgetUseCase: View {
    
    private let navigationViewModel: NavigationViewModel
    
    @State var clickedUrl: URL?
    
    private let paramsViewModel: ParamsViewModel
    
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self.paramsViewModel = paramsViewModel
    }
    
    
    var body: some View {
        VStack {
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
                }
            }
            
            
            OutbrainWidgetView(
                url: paramsViewModel.articleURL,
                widgetId: paramsViewModel.staticWidgetId,
                widgetIndex: 0,
                installationKey: "NANOWDGT01",
                userId: nil,
                darkMode: paramsViewModel.darkMode,
                onRecClick: { url in
                    clickedUrl = url
                }) { url in
                    navigationViewModel.push(.staticWidget)
                }
                .frame(height: 50)
            
        }
        .fullScreenCover(isPresented: .init(
            get: { clickedUrl != nil },
            set: { value in
                if !value {
                    clickedUrl = nil
                }
            }
        )) {
            OBSafariView(url: $clickedUrl.wrappedValue!)
                .ignoresSafeArea(edges: .all)
        }
    }
}
