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
    private let paramsViewModel: ParamsViewModel
    @State var clickedUrl: URL?
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel,
        organicUrl: String?
    ) {
        self.navigationViewModel = navigationViewModel
        self.organicUrl = organicUrl
        self.paramsViewModel = paramsViewModel
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
                        url: paramsViewModel.articleURL,
                        widgetId: paramsViewModel.bridgeWidgetId2,
                        widgetIndex: 0,
                        installationKey: "NANOWDGT01",
                        userId: nil,
                        darkMode: paramsViewModel.darkMode,
                        onRecClick: { url in
                            clickedUrl = url
                        }, onOrganicRecClick: { url in
                            navigationViewModel.push(.organic(url.absoluteString))
                        })
                }
                
            }
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
