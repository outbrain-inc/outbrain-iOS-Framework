//
//  SwiftUIViewabilityView.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 14/08/2024.
//

import Foundation
import SwiftUI


@available(iOS 15.0, *)
struct SwiftUIViewabilityViewModifier: ViewModifier {
    
    let recommendation: OBRecommendation
    let viewabilityKey: String
    
    init(recommendation: OBRecommendation) {
        self.recommendation = recommendation
        self.viewabilityKey = OBViewbailityManager.shared.viewabilityKey(
            for: recommendation.reqId ?? "",
            position: recommendation.position ?? "0"
        )
        
        OBViewbailityManager.shared.registerViewabilityKey(
            key: viewabilityKey,
            positions: [recommendation.position ?? ""],
            requestId: recommendation.reqId!,
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
                    
                    Rectangle()
                        .fill(Color.clear) // Visible background color for the second half
                        .frame(maxHeight: .infinity)
                        .onAppear {
                            OBViewbailityManager.shared.reportViewability(for: viewabilityKey)
                            
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                                OBViewbailityManager.shared.report()
                            }
                        }
                }
            }
    }
}


@available(iOS 15.0, *)
extension View {
    
    public func addViewability(with recommendation: OBRecommendation) -> some View {
        self.modifier(SwiftUIViewabilityViewModifier(recommendation: recommendation))
    }
}
