//
//  BridgeUtils.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 30/07/2023.
//

import Foundation
import UIKit

struct BridgeUtils {
    
    static func addConstraintsToParentView(view: UIView) {
        guard let parentView = view.superview else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0),
            view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0)
        ])
        
        view.setNeedsLayout()
    }
    
    static func addConstraintsToFillParent(view: UIView) {
        guard let parentView = view.superview else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
        
        view.setNeedsLayout()
    }
    
    static func isValidURL(_ string: String) -> Bool {
        if let _ = URL(string: string) {
            return true
        } else {
            return false
        }
    }

}
