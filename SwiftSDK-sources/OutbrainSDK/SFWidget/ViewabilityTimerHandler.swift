//
//  Viewability.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 16/08/2023.
//

import UIKit


class ViewabilityTimerHandler {
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
    private var viewabilityTimer: Timer?
    
    
    struct ViewParams {
        var visibleFrom = 0
        var visibleTo = 0
    }
    

    func handleViewability(
        sfWidget: SFWidget?,
        containerView: UIView,
        viewabilityClosure: @escaping (_ viewParams: ViewParams, _ width: Int, _ height: Int) -> Void
    ) {
        guard let sfWidget, !sfWidget.isSwiftUI else { return }
        
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
    
    
    func handleSwiftUI(
        sfWidget: SFWidget?,
        viewabilityClosure: @escaping (_ viewParams: ViewParams, _ width: Int,_ height: Int,_ shouldLoadMore: Bool) -> Void
    ) {
        viewabilityTimer?.invalidate() // Invalidate any existing timer
        viewabilityTimer = Timer.scheduledTimer(withTimeInterval: self.swiftUIInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            let viewParams = self.handleViewabilitySwiftUI(sfWidget)
            
            guard let viewParams else {
                self.viewabilityTimer?.invalidate()
                return
            }
            
            var shouldLoadMore = false
            
            if let sfWidget {
                let viewport = sfWidget.convert(UIScreen.main.bounds, from: nil as UIView?)
                let viewportBottom = viewport.maxY
                
                shouldLoadMore = sfWidget.currentHeight - viewportBottom < SFConsts.THRESHOLD_FROM_BOTTOM
            }
            
            viewabilityClosure(viewParams, self.webViewWidth,  self.webViewHeight, shouldLoadMore)
        }
    }
    
    
    private func handleViewabilitySwiftUI(_ sfWidget: SFWidget?) -> ViewParams? {
        guard let widget = sfWidget,
              widget.isSwiftUI,
              widget.window != nil else {
            return nil
        }
        
        let viewParams = ViewParams()
        let scale = UIScreen.main.scale
        
        webViewHeight = Int(widget.bounds.size.height * scale)
        webViewWidth = Int(widget.bounds.size.width * scale)
        viewFrame = widget.convert(widget.bounds, to: nil)
        intersection = viewFrame.intersection(widget.window!.frame)
        intersectionHeight = Int(intersection.size.height)
        containerViewHeight = Double(widget.window!.frame.size.height)
        distanceToContainerTop = (widget.window!.frame.minY - viewFrame.minY) * scale
        distanceToContainerBottom = Int((widget.window!.frame.maxY - viewFrame.minY) * scale)

        guard intersection.size.height > 0 else {
            return viewParams
        }
        
        return checkViewStatusSwiftUI(scale: scale)
    }
    
    
    private func checkViewStatusSwiftUI(scale: Double) -> ViewParams {
        var viewParams = ViewParams()
        // webview on screen
        if distanceToContainerTop < 0 {
            // top
            viewParams.visibleFrom = 0
            viewParams.visibleTo = Int(distanceToContainerBottom)
            return viewParams
        }
        
        if Double(intersectionHeight) < containerViewHeight {
            // bottom
            viewParams.visibleFrom = Int(webViewHeight - (intersectionHeight * Int(scale)))
            viewParams.visibleTo = Int(webViewHeight)
            return viewParams
        }
        
        // full
        viewParams.visibleFrom = Int(distanceToContainerTop)
        viewParams.visibleTo = Int(distanceToContainerTop) + Int(intersectionHeight * Int(scale))
        return viewParams
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
