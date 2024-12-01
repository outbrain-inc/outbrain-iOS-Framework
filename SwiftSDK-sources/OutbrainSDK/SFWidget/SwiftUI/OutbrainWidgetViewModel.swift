//
//  OutbrainWidgetViewModel.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 21/11/2024.
//

import SwiftUI


final class OutbrainWidgetViewModel: ObservableObject {
    
    @Published var widgetHeight: CGFloat = 0
    @Published var clickedUrl: URL?
    
    let widget: SFWidget = SFWidget()
    let onOrganicRecClick: ((URL) -> Void)?
    let onWidgetEvent: ((String, [String: Any]) -> Void)?
    
    
    init(
        onOrganicRecClick: ((URL) -> Void)? = nil,
        onWidgetEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.onOrganicRecClick = onOrganicRecClick
        self.onWidgetEvent = onWidgetEvent
    }
}
