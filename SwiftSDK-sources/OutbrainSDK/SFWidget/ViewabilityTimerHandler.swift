//
//  Viewability.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 16/08/2023.
//

import UIKit

let LOAD_DISTANCE_THRESHOLD: CGFloat = THRESHOLD_FROM_BOTTOM

struct ViewParams {
    var visibleFrom = 0
    var visibleTo = 0
}

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
    
    init() {
        
    }

    func handleViewability(sfWidget: SFWidget?, containerView: UIView, viewabilityClosure: @escaping (_ viewParams: ViewParams,_ width: Int,_ height: Int) -> Void) {
        guard let widget = sfWidget, !widget.isSwiftUI else {
            return
        }
        
        let scale = UIScreen.main.scale
        
        self.viewFrame = widget.convert(widget.bounds, to: nil)
        self.intersection = viewFrame.intersection(containerView.frame)
        self.intersectionHeight = Int(round(self.intersection.size.height * scale))
        self.containerViewHeight = containerView.frame.size.height * scale
        self.roundedContainerViewHeight = Int(round(self.containerViewHeight))
        self.webViewHeight = Int(round(self.viewFrame.size.height * scale))
        self.distanceToContainerTop = (containerView.frame.minY - self.viewFrame.minY) * scale
        self.distanceToContainerBottom = Int((containerView.frame.maxY - self.viewFrame.minY) * scale)
        self.webViewWidth = Int(round(self.viewFrame.size.width * scale))
        
        let isViewVisible = self.distanceToContainerBottom > 0 && self.containerViewHeight != Double(self.distanceToContainerBottom) && self.intersectionHeight != 0
        
        if !isViewVisible {
            return
        }
        
        let viewStatus = self.checkViewStatus()
        viewabilityClosure(viewStatus, self.webViewWidth, self.webViewHeight)
    }
    
    func handleSwiftUI(sfWidget: SFWidget?, viewabilityClosure: @escaping (_ viewParams: ViewParams, _ width: Int,_ height: Int,_ shouldLoadMore: Bool) -> Void ) {
        self.viewabilityTimer?.invalidate() // Invalidate any existing timer

        self.viewabilityTimer = Timer.scheduledTimer(withTimeInterval: self.swiftUIInterval, repeats: true) { _ in
            

            let viewParams = self.handleViewabilitySwiftUI(sfWidget)
            
            if let viewParams = viewParams {
                var shouldLoadMore = false;
                
                if let widget = sfWidget {
                    let viewport = widget.convert(UIScreen.main.bounds, from: nil as UIView?)
                    let viewportBottom = viewport.maxY
                    
                    shouldLoadMore = widget.currentHeight - viewportBottom < LOAD_DISTANCE_THRESHOLD
                }

                viewabilityClosure(viewParams, self.webViewWidth,  self.webViewHeight, shouldLoadMore)
                return
            }
            self.viewabilityTimer?.invalidate()
        }
    }
    
    private func handleViewabilitySwiftUI(_ sfWidget: SFWidget?) -> ViewParams? {
        guard let widget = sfWidget, widget.isSwiftUI, widget.window != nil else {
            return nil
        }
        
        let viewParams = ViewParams()
        let scale = UIScreen.main.scale
        self.webViewHeight = Int(widget.bounds.size.height * scale)
        self.webViewWidth = Int(widget.bounds.size.width * scale)
        self.viewFrame = widget.convert(widget.bounds, to: nil)
        self.intersection = viewFrame.intersection(widget.window!.frame)
        self.intersectionHeight = Int(intersection.size.height)
        self.containerViewHeight = Double(widget.window!.frame.size.height)
        self.distanceToContainerTop = (widget.window!.frame.minY - viewFrame.minY) * scale
        self.distanceToContainerBottom = Int((widget.window!.frame.maxY - viewFrame.minY) * scale)

        
        if intersection.size.height == 0 {
            return viewParams
        }

        
        return self.checkViewStatusSwiftUI(scale: scale)
        
    }
    
    private func checkViewStatusSwiftUI(scale: Double) -> ViewParams {
        var viewParams = ViewParams()
        // webview on screen
        if distanceToContainerTop < 0 {
            // top
            viewParams.visibleFrom = 0
            viewParams.visibleTo = Int(self.distanceToContainerBottom)
            return viewParams
        }
        
        if Double(self.intersectionHeight) < self.containerViewHeight {
            // bottom
            viewParams.visibleFrom = Int(self.webViewHeight - (self.intersectionHeight * Int(scale)))
            viewParams.visibleTo = Int(self.webViewHeight)
            return viewParams
        }
        
        // full
        viewParams.visibleFrom = Int(self.distanceToContainerTop)
        viewParams.visibleTo = Int(self.distanceToContainerTop) + Int(self.intersectionHeight * Int(scale))
        return viewParams
    }
    
    private func checkViewStatus() -> ViewParams {
        var viewParams = ViewParams()

        if (self.distanceToContainerTop < 0 ) {
            // top
            viewParams.visibleFrom = 0
            viewParams.visibleTo = self.distanceToContainerBottom
            return viewParams
        }
        
        if (Double(self.intersectionHeight) < self.containerViewHeight) {
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
