//
//  OBRecCell.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/7/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit

class OBRecCell: UITableViewCell {

    @IBOutlet weak var recImageView: UIImageView!
    
    @IBOutlet weak var recTitle: UILabel!
    
    @IBOutlet weak var recSource: UILabel!
    
    @IBOutlet weak var adChoicesButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let v = UIView(frame: self.bounds)
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.selectedBackgroundView = v;
        self.contentView.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
