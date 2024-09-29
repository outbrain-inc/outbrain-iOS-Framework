//
//  Viewability.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 16/08/2023.
//

import UIKit


class ViewabilityHandler {
    
    var webViewHeight = 0
    var webViewWidth = 0
    var distanceToContainerTop = 0.0
    var intersectionHeight = 0
    var containerViewHeight = 0.0
    var roundedContainerViewHeight = 0
    var distanceToContainerBottom = 0
    var viewFrame: CGRect!
    var intersection: CGRect!
    let swiftUIInterval: TimeInterval = 0.2
    
    
    struct ViewParams {
        var visibleFrom = 0
        var visibleTo = 0
    }
    

    func handleViewability(
        sfWidget: SFWidget?,
        containerView: UIView,
        viewabilityClosure: @escaping (_ viewParams: ViewParams, _ width: Int, _ height: Int) -> Void
    ) {
        guard let sfWidget else { return }
        
        let scale = UIScreen.main.scale
        
        viewFrame = sfWidget.convert(sfWidget.bounds, to: nil)
        intersection = viewFrame.intersection(containerView.frame)
        intersectionHeight = Int(round(intersection.size.height * scale))
        containerViewHeight = containerView.frame.size.height * scale
        roundedContainerViewHeight = Int(round(containerViewHeight))
        webViewHeight = Int(round(viewFrame.size.height * scale))
        distanceToContainerTop = (containerView.frame.minY - viewFrame.minY) * scale
        distanceToContainerBottom = Int((containerView.frame.maxY - viewFrame.minY) * scale)
        webViewWidth = Int(round(viewFrame.size.width * scale))
        
        let isViewVisible = distanceToContainerBottom > 0
        && containerViewHeight != Double(distanceToContainerBottom)
        && self.intersectionHeight != 0
        
        guard isViewVisible else { return }
        
        let viewStatus = checkViewStatus()
        viewabilityClosure(viewStatus, webViewWidth, webViewHeight)
    }
    
    
    private func checkViewStatus() -> ViewParams {
        var viewParams = ViewParams()

        if (distanceToContainerTop < 0 ) {
            // top
            viewParams.visibleFrom = 0
            viewParams.visibleTo = distanceToContainerBottom
            return viewParams
        }
        
        if (Double(intersectionHeight) < containerViewHeight) {
            // bottom
            viewParams.visibleFrom = webViewHeight - intersectionHeight
            viewParams.visibleTo = webViewHeight
            return viewParams
        }
        

        // full
        viewParams.visibleFrom = Int(round(distanceToContainerTop))
        viewParams.visibleTo = Int(round(distanceToContainerTop)) + roundedContainerViewHeight
        return viewParams
    }
}
