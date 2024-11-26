//
//  SFWidgetWebView.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 24/11/2024.
//

import WebKit
import UIKit


internal class SFWidgetWebView: WKWebView, UIGestureRecognizerDelegate {
    
    private var panGesture: UIPanGestureRecognizer?
    private var isHorizontalSwipe = false
    
    
    func enableSwipeOverride() {
        setupGesture()
    }
    
    
    private func setupGesture() {
        guard panGesture == nil else { return }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture!.delegate = self
        self.addGestureRecognizer(panGesture!)
    }
    
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self)
            if abs(translation.x) > abs(translation.y) {
                return false
            }
        }
        return true
    }
    
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
            case .began:
                break
            case .changed:
                isHorizontalSwipe = abs(translation.x) > abs(translation.y) // Check swipe direction
            case .ended, .cancelled:
                isHorizontalSwipe = false
            default:
                break
        }
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHorizontalSwipe {
            return self // Return self to handle touches in this view
        }
        
        return super.hitTest(point, with: event)
    }
}
