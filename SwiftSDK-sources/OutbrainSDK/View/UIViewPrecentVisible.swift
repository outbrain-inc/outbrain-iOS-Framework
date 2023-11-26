//
//  UIViewPrecentVisible.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 27/06/2023.
//

import UIKit

// Extend UIView to calculate the percent visible
extension UIView {
    // Calculate the percent visible
    func percentVisible() -> CGFloat {
        // convert view's frame to window's coordinate system
        let viewFrame = convert(bounds, to: nil)
        
        // get the intersection between view and window
        let intersection = viewFrame.intersection(window?.frame ?? CGRect.zero)
        
        // calculate the intersection area
        let intersectionArea = intersection.size.width * intersection.size.height
        
        // calculate the view area
        let viewArea = frame.size.width * frame.size.height
        
        // calculate the percent visible
        let percentVisible = intersectionArea / viewArea
        
        // return the percent visible
        return percentVisible
    }
}
