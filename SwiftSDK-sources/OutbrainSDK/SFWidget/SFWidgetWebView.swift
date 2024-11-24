//
//  SFWidgetWebView.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 24/11/2024.
//

import WebKit
import UIKit


internal class SFWidgetWebView: WKWebView, UIGestureRecognizerDelegate {
    
    var panGesture: UIPanGestureRecognizer?
    
    
    func enableSwipeOverride() {
        setupGesture()
    }
    
    
    private func setupGesture() {
        guard panGesture == nil else { return }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture!.delegate = self
        self.addGestureRecognizer(panGesture!)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Check if the gesture recognizer is a pan gesture
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            // Determine the direction of the pan gesture
            let translation = panGesture.translation(in: self)
            if abs(translation.x) > abs(translation.y) {
                // Intercept horizontal swipes
                return false // Prevent the web view from recognizing horizontal swipes
            }
        }
        return true // Allow other gestures to be recognized simultaneously
    }
    
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
            case .changed:
                // Check if the gesture is primarily vertical
                if abs(translation.y) > abs(translation.x) {
                    // Allow vertical scrolling
                } else {
                    // Handle horizontal gestures (e.g., swiping left/right)
                    gesture.isEnabled = false // Disable the gesture temporarily
                    gesture.isEnabled = true // Re-enable to allow further gestures
                }
            case .ended, .cancelled:
                // Handle the end of the gesture if needed
                break
            default:
                break
        }
    }
}
