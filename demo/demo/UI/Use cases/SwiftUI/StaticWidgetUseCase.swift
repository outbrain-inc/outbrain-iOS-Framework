//
//  StaticWidgetUseCase.swift
//  demo
//
//  Created by Leonid Lemesev on 05/11/2024.
//

import SwiftUI


struct StaticWidgetUseCase: View {
    
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
        VStack {
            Text("The Guardian")
                .padding()
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 80.0)
                .background(.blue)
                .foregroundColor(.white)
            
            
            OutbrainWidgetView(
                viewModel: viewModel,
                twoWidgets: true,
                widgetIndex: 0
            )
        }
    }
}
