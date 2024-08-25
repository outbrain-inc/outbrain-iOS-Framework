//
//  SwiftUIViewabilityView.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 14/08/2024.
//

import Foundation
import SwiftUI


@available(iOS 15.0, *)
private struct SwiftUIViewabilityViewModifier: ViewModifier {
    
    let recommendation: OBRecommendation
    let viewabilityKey: String
    @State var shouldReport = false
    @State var reportTimer: Timer?
    
    
    init(recommendation: OBRecommendation) {
        self.recommendation = recommendation
        self.viewabilityKey = OBViewbailityManager.shared.viewabilityKey(
            for: recommendation.reqId ?? "",
            position: recommendation.position ?? "0"
        )
        
        guard let reqId = recommendation.reqId else { return }
        OBViewbailityManager.shared.registerViewabilityKey(
            key: viewabilityKey,
            positions: [recommendation.position ?? ""],
            requestId: reqId,
            initializationTime: OBGlobalStatisticsManager.shared.initializationTime(forReqId: recommendation.reqId!)
        )
    }
    
    
    func body(content: Content) -> some View {
        content
            .background {
                
                VStack {
                    Rectangle()
                        .fill(Color.clear) // Visible background color for the first half
                        .frame(maxHeight: .infinity)
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear) // Visible background color for the second half
                            .frame(maxHeight: .infinity)
                            .preference(
                                key: VisibleKey.self,
                                // See discussion!
                                value: UIScreen.main.bounds.intersects(geometry.frame(in: .global))
                            )
                    }
                }
            }
            .onPreferenceChange(VisibleKey.self) { isVisible in
                shouldReport = isVisible
                reportTimer?.invalidate()
                reportTimer = nil
                
                guard isVisible else { return }
                
                reportTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                    if shouldReport && !viewabilityKey.isEmpty {
                        OBViewbailityManager.shared.reportViewability(for: viewabilityKey)
                        OBViewbailityManager.shared.report()
                    }
                }
            }
    }
}


private struct VisibleKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { }
}


@available(iOS 15.0, *)
extension View {
    
    public func addViewability(with recommendation: OBRecommendation) -> some View {
        self.modifier(SwiftUIViewabilityViewModifier(recommendation: recommendation))
    }
}
