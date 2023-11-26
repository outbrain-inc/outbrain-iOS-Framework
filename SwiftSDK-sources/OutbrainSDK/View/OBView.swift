//
//  OBView.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 29/06/2023.
//

import Foundation
import UIKit

class OBView: UIView {
    internal var viewVisibleTimer: Timer? // Timer to track viewability
    var key: String? // Viewability key
    
    // Init with frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        trackViewability()
    }
    
    // Init with coder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        trackViewability()
    }
    
    override func draw(_ rect: CGRect) {
        // Call the super draw method
        super.draw(rect)
    }
    
    // Check if the viewability timer is running
    func isTimerRunning() -> Bool {
        return viewVisibleTimer != nil && viewVisibleTimer!.isValid
    }
    
    // track viewability
    internal func trackViewability() {
        // If the timer is already running, do nothing
        if isTimerRunning() {
            return
        }
        
        // start a timer to track viewability
        viewVisibleTimer = Timer.scheduledTimer(timeInterval: OB_VIEW_CONSTANTS.TIMER_INTERVAL, target: self, selector: #selector(checkIfViewIsVisible(_:)), userInfo: NSMutableDictionary(), repeats: true)
        viewVisibleTimer?.tolerance = OB_VIEW_CONSTANTS.TIMER_INTERVAL * 0.5
        
        // Add the timer to the main run loop
        RunLoop.main.add(viewVisibleTimer!, forMode: .common)
    }
    
    // check if the view is visible
    @objc internal func checkIfViewIsVisible(_ timer: Timer) {
        if self.superview == nil {
            viewVisibleTimer?.invalidate()
            return
        }
        
        // Get the view's percent visible
        let percentVisible = self.percentVisible()
        
        // Get the view's miliseconds visible
        var milisecondsVisible = ((timer.userInfo as? NSMutableDictionary)?["milisecondsVisible"] as? CGFloat) ?? 0.0
        
        if percentVisible >= 0.5 && milisecondsVisible < OB_VIEW_CONSTANTS.VIEW_THRESHOLD_MS {
            // If the view is more than 50% visible and the view has been visible for less than the viewability threshold, add the timer interval to the miliseconds visible
            milisecondsVisible += CGFloat(timer.timeInterval * Double(OB_VIEW_CONSTANTS.VIEW_THRESHOLD_MS))
            (timer.userInfo as? NSMutableDictionary)?["milisecondsVisible"] = milisecondsVisible
        } else if percentVisible >= 0.5 && milisecondsVisible >= OB_VIEW_CONSTANTS.VIEW_THRESHOLD_MS {
            // If the view is more than 50% visible and the view has been visible for more than the viewability threshold, report viewability and stop the timer
            reportViewability(timer)
        } else {
            // If the view is less than 50% visible, reset the miliseconds visible
            (timer.userInfo as? NSMutableDictionary)?.removeObject(forKey: "milisecondsVisible")
        }
    }
    
    // Report viewability
    @objc internal func reportViewability(_ timer: Timer) {
        // Stop the viewability timer
        timer.invalidate()
        
        // Report viewability
        OBViewbailityManager.shared.reportViewability(for: self)
        
        // Remove the view from its superview
        removeFromSuperview()
    }
    
    override func removeFromSuperview() {
        // Stop the viewability timer
        if let viewVisibleTimer = viewVisibleTimer {
            viewVisibleTimer.invalidate()
        }
        
        // Remove the view from its superview
        super.removeFromSuperview()
    }
}

enum OB_VIEW_CONSTANTS {
    static let TIMER_INTERVAL: TimeInterval = 0.1 // Timer interval
    static let VIEW_THRESHOLD_MS: CGFloat = 1000 // Viewability threshold in miliseconds
}

