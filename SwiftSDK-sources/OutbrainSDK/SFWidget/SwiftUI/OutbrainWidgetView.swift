//
//  OutbrainWidgetView.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 21/11/2024.
//

import SwiftUI


public struct OutbrainWidgetView: View {
    
    @StateObject var viewModel: OutbrainWidgetViewModel

    let url: String
    let widgetId: String
    let widgetIndex: Int
    let installationKey: String
    let userId: String?
    let darkMode: Bool

    
    public init(
        url: String,
        widgetId: String,
        widgetIndex: Int,
        installationKey: String,
        userId: String?,
        darkMode: Bool,
        onRecClick: ((URL) -> Void)?,
        onOrganicRecClick: ((URL) -> Void)? = nil,
        onWidgetEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.url = url
        self.widgetId = widgetId
        self.widgetIndex = widgetIndex
        self.installationKey = installationKey
        self.userId = userId
        self.darkMode = darkMode
        self._viewModel = .init(
            wrappedValue: .init(
                onRecClick: onRecClick,
                onOrganicRecClick: onOrganicRecClick,
                onWidgetEvent: onWidgetEvent
            )
        )
    }

    
    public var body: some View {
        OutbrainWidgetUIViewRepresentable(
            viewModel: viewModel,
            config: .init(
                url: url,
                widgetId: widgetId,
                widgetIndex: widgetIndex,
                installationKey: installationKey,
                userId: userId,
                darkMode: darkMode
            )
        )
            .frame(height: viewModel.widgetHeight)
    }
}
