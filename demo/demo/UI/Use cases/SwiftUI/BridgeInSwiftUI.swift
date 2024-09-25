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
    
    
    init(params: ParamsViewModel) {
        self.params = params
        self._viewModel = .init(wrappedValue: OutbrainWidgetViewModel(paramsViewModel: params))
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
                    
                    OutbrainWidgetView(viewModel: viewModel)
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

#Preview {
    BridgeInSwiftUI(params: .init())
}
