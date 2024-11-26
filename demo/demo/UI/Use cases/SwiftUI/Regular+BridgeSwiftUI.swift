//
//  Regular+BridgeSwiftUI.swift
//  demo
//
//  Created by Leonid Lemesev on 26/09/2024.
//

import SwiftUI
import OutbrainSDK


struct RegularAndBridgeSwiftUI: View {
    
    
    private let navigationViewModel: NavigationViewModel
    
    @State private var recommendations: [Recommendation] = []
    
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
                    
                    
                    ForEach(recommendations) { rec in
                        if let content = rec.recommendation.content {
                            HStack {
                                AsyncImage(url: rec.recommendation.image?.url, content: { image in
                                    image.resizable()
                                    image.aspectRatio(contentMode: .fit)
                                }, placeholder: {
                                    
                                })
                                .frame(width: 100, height: 100)
                                .clipped()
                                
                                VStack(alignment: .leading) {
                                    Text(content)
                                    Text(rec.recommendation.source ?? "")
                                }
                            }
                            .onTapGesture {
                                if rec.recommendation.isPaidLink {
                                    clickedUrl = Outbrain.getUrl(rec.recommendation)
                                } else {
                                    navigationViewModel.push(.regularAndBridgeSwiftUI)
                                }
                            }
                            .addViewability(with: rec.recommendation)
                        }
                    }
                    
                    ArticleBody()
                    ArticleBody()
                    
                    
                    OutbrainWidgetView(
                        url: paramsViewModel.articleURL,
                        widgetId: paramsViewModel.bridgeWidgetId,
                        widgetIndex: 0,
                        installationKey: "NANOWDGT01",
                        darkMode: paramsViewModel.darkMode) { url in
                            navigationViewModel.push(.regularAndBridgeSwiftUI)
                        }
                }
            }
        }
        .onAppear {
            let request = OBRequest(
                url: paramsViewModel.articleURL,
                widgetID: paramsViewModel.regularWidgetId,
                widgetIndex: 0
            )
            
            
            Task {
                guard let obRecs = try? await Outbrain.fetchRecommendations(for: request) else { return }
                recommendations = obRecs.map { .init(recommendation: $0) }
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
            OutbrainSafariView(url: $clickedUrl.wrappedValue!)
                .ignoresSafeArea(edges: .all)
        }
    }
}


#Preview {
    RegularAndBridgeSwiftUI(navigationViewModel: .init(), paramsViewModel: .init())
}
