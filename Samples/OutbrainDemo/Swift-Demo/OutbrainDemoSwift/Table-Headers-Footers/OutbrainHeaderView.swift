//
//  OutbrainHeaderView.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/14/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit
import OutbrainSDK

class OutbrainHeaderView: UIView {

    @IBOutlet weak var recommendedToYouLabel: OBLabel!

    @IBOutlet weak var outbrainLogoButton: UIButton!

    
    static let nibName = "OutbrainHeaderView"

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}

extension UIViewLoading where Self : UIView {
    
    static func loadHeaderFromNib() -> Self {
        return OutbrainHeaderView.nib.instantiate(withOwner: self, options: nil).first as! Self
    }
    
}
