//
//  TwoWidgetsSwiftuI.swift
//  demo
//
//  Created by Leonid Lemesev on 26/09/2024.
//


import SwiftUI
import OutbrainSDK



struct TwoWidgetsSwiftuI: View {
    
    private let navigationViewModel: NavigationViewModel
    private let paramsViewModel: ParamsViewModel
    
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self.paramsViewModel = paramsViewModel
        SFWidget.infiniteWidgetsOnTheSamePage = true
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
                
                OutbrainWidgetView(
                    url: paramsViewModel.articleURL,
                    widgetId: paramsViewModel.bridgeWidgetId2,
                    widgetIndex: 0,
                    installationKey: "NANOWDGT01",
                    darkMode: paramsViewModel.darkMode) { url in
                        navigationViewModel.push(.twoWidgetsSwiftUI)
                    }
                
                
                ArticleBody()
                ArticleBody()
                
                OutbrainWidgetView(
                    url: paramsViewModel.articleURL,
                    widgetId: paramsViewModel.bridgeWidgetId,
                    widgetIndex: 1,
                    installationKey: "NANOWDGT01",
                    darkMode: paramsViewModel.darkMode) { url in
                        navigationViewModel.push(.twoWidgetsSwiftUI)
                    }
            }
        }
    }
}
