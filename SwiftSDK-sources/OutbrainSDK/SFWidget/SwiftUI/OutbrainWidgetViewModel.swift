//
//  OutbrainWidgetViewModel.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 21/11/2024.
//

import SwiftUI


final class OutbrainWidgetViewModel: ObservableObject {
    
    let widget: SFWidget = SFWidget()
    
    @Published var widgetHeight: CGFloat = 0
    let onRecClick: ((URL) -> Void)?
    let onOrganicRecClick: ((URL) -> Void)?
    let onWidgetEvent: ((String, [String: Any]) -> Void)?
    
    
    init(
        onRecClick: ((URL) -> Void)? = nil,
        onOrganicRecClick: ((URL) -> Void)? = nil,
        onWidgetEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.onRecClick = onRecClick
        self.onOrganicRecClick = onOrganicRecClick
        self.onWidgetEvent = onWidgetEvent
    }
}

