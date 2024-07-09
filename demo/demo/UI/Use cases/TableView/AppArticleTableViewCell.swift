//
//  AppArticleTableViewCell.swift
//  OutbrainDemo
//
//  Created by oded regev on 30/08/2018.
//  Copyright © 2018 Outbrain inc. All rights reserved.
//

import UIKit

class AppArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
