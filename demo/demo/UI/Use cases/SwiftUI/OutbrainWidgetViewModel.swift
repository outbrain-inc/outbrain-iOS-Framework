//
//  OutbrainListItemViewModel.swift
//  OutbrainSwiftUI
//
//  Created by Mikhail Vasilev on 22.07.24.
//

import Foundation
import OutbrainSDK

final class OutbrainWidgetViewModel: ObservableObject {

    let widget: SFWidget = SFWidget()
    
    @Published
    var widgetHeight: CGFloat = 800
}
