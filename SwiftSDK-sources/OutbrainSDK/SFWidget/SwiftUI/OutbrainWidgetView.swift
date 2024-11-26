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
    let extId: String?
    let extSecondaryId: String?
    let OBPubImp: String?
    
    
    public init(
        url: String,
        widgetId: String,
        widgetIndex: Int,
        installationKey: String,
        userId: String? = nil,
        darkMode: Bool = false,
        extId: String? = nil,
        extSecondaryId: String? = nil,
        OBPubImp: String? = nil,
        onOrganicRecClick: ((URL) -> Void)? = nil,
        onWidgetEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.url = url
        self.widgetId = widgetId
        self.widgetIndex = widgetIndex
        self.installationKey = installationKey
        self.userId = userId
        self.darkMode = darkMode
        self.extId = extId
        self.extSecondaryId = extSecondaryId
        self.OBPubImp = OBPubImp
        
        self._viewModel = .init(
            wrappedValue: .init(
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
                darkMode: darkMode,
                extId: extId,
                extSecondaryId: extSecondaryId,
                OBPubImp: OBPubImp
            )
        )
        .frame(height: viewModel.widgetHeight)
        .fullScreenCover(isPresented: .init(
            get: { viewModel.clickedUrl != nil },
            set: { value in
                if !value {
                    viewModel.clickedUrl = nil
                }
            }
        )) {
            OutbrainSafariView(url: $viewModel.clickedUrl.wrappedValue!)
                .ignoresSafeArea(edges: .all)
        }
    }
}
