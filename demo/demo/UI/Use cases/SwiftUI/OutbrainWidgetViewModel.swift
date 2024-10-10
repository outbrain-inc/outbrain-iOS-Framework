//
//  OutbrainListItemViewModel.swift
//  OutbrainSwiftUI
//
//  Created by Mikhail Vasilev on 22.07.24.
//

import Foundation
import OutbrainSDK

final class OutbrainWidgetViewModel: ObservableObject {

    let navigationViewModel: NavigationViewModel
    let widget: SFWidget = SFWidget()
    
    @Published var clickedUrl: URL? = nil
    @Published var widgetHeight: CGFloat = 800
    
    
    init(navigationViewModel: NavigationViewModel) {
        self.navigationViewModel = navigationViewModel
    }
}
