//
//  RegularSDK.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI
import OutbrainSDK
import SafariServices


struct RegularSDK: View {
    
    @State private var recommendations: [Recommendation] = []
    @State private var showSafari: Bool = false
    @State private var clickedUrl: URL? = nil
    
    let paramsViewModel: ParamsViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
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
                    .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 0    ))
                
                ArticleBody()
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
                            clickedUrl = Outbrain.getUrl(rec.recommendation)
                        }
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
            
            
            Outbrain.fetchRecommendations(for: request) { response in
                guard let reqs = response?.recommendations else {
                    return
                }
                
                recommendations = reqs
                    .compactMap { $0 as? OBRecommendation }
                    .map { .init(recommendation: $0) }
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



#Preview {
    RegularSDK(paramsViewModel: .init())
}


struct Recommendation: Identifiable {
    let id = UUID()
    let recommendation: OBRecommendation
}
