//
//  Regular+BridgeSwiftUI.swift
//  demo
//
//  Created by Leonid Lemesev on 26/09/2024.
//

import SwiftUI
import OutbrainSDK


struct RegularAndBridgeSwiftUI: View {
    
    
    let paramsViewModel: ParamsViewModel
    
    @State private var recommendations: [Recommendation] = []
    
    @StateObject
    private var viewModel: OutbrainWidgetViewModel
    
    
    init(paramsViewModel: ParamsViewModel) {
        self.paramsViewModel = paramsViewModel
        self._viewModel = .init(wrappedValue: OutbrainWidgetViewModel(paramsViewModel: paramsViewModel))
    }
    
    
    var body: some View {
        ScrollView {
            ZStack {
                LazyVStack {
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
                                viewModel.clickedUrl = Outbrain.getUrl(rec.recommendation)
                            }
                            .addViewability(with: rec.recommendation)
                        }
                    }
                    
                    ArticleBody()
                    ArticleBody()
                    
                    
                    OutbrainWidgetView(viewModel: viewModel)
                        .frame(height: viewModel.widgetHeight)
                }
                
            }
        }
        .onAppear {
            let request = OBRequest(
                url: paramsViewModel.articleURL,
                widgetID: paramsViewModel.regularWidgetId,
                widgetIndex: 0
            )
            
            
            Outbrain.fetchRecommendations(for: request) { response in
                recommendations = response.recommendations
                    .map { .init(recommendation: $0) }
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


#Preview {
    RegularAndBridgeSwiftUI(paramsViewModel: .init())
}
