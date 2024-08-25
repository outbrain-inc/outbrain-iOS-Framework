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



struct RegularInUIKit: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ScrollViewVC
    
    let paramsViewModel: ParamsViewModel
    
    func makeUIViewController(context: Context) -> ScrollViewVC {
        // Instantiate your UIKit view controller here
        let articleVC = ScrollViewVC(
            paramsViewModel: paramsViewModel,
            isRegular: true
        )
        return articleVC
    }
    
    
    func updateUIViewController(_ uiViewController: ScrollViewVC, context: Context) {
        // Update the view controller when your SwiftUI state changes, if necessary
    }
}



//struct RegularSDKUiKit: View {
//    
//    @State private var recommendations: [Recommendation] = []
//    @State private var showSafari: Bool = false
//    @State private var clickedUrl: URL? = nil
//    
//    let paramsViewModel: ParamsViewModel
//    
//    var body: some View {
//        ScrollView(.vertical) {
//            VStack(alignment: .leading) {
//                
//                Image("articleImage", bundle: Bundle.main)
//                    .resizable()
//                    .aspectRatio(16/9, contentMode: .fill)
//                
//                Text("The Guardian")
//                    .padding()
//                    .font(.headline)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .frame(height: 80.0)
//                    .background(.blue)
//                    .foregroundColor(.white)
//                
//                Text("Suarez: Messi Was Born Great, Ronaldo Made Himself Great")
//                    .font(.system(size: 24))
//                    .fontWeight(.medium)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 0    ))
//                
//                ArticleBody()
//                ArticleBody()
//                ArticleBody()
//                
//                ForEach(recommendations) { rec in
//                    RecommendationViewWrapper(rec: rec.recommendation)
//                        .frame(height: 100)
//                        .frame(maxWidth: .infinity)
//                        .onTapGesture {
//                            clickedUrl = Outbrain.getUrl(rec.recommendation)
//                        }
//                        .onAppear {
//                            
//                        }
//                }
//            }
//        }
//        .onAppear {
//            let request = OBRequest(
//                url: paramsViewModel.articleURL,
//                widgetID: paramsViewModel.regularWidgetId,
//                widgetIndex: 0
//            )
//            
//            
//            Outbrain.fetchRecommendations(for: request) { response in
//                recommendations = response.recommendations
//                    .map { .init(recommendation: $0) }
//            }
//        }
//        .fullScreenCover(isPresented: .init(
//            get: { clickedUrl != nil },
//            set: { value in
//                if !value {
//                    clickedUrl = nil
//                }
//            }
//        )) {
//            OBSafariView(url: $clickedUrl.wrappedValue!)
//                .ignoresSafeArea(edges: .all)
//        }
//    }
//}
//
//
//
//#Preview {
//    RegularSDKUiKit(paramsViewModel: .init())
//}
//
//
