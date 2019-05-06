//
//  OutbrainFooterView.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/7/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit
import OutbrainSDK
import Alamofire
import AlamofireImage

protocol OutbrainFooterViewDelegate {

    // protocol definition goes here
    func heightHasChanged();
    
    func userTappedRecommendation(_ rec:OBRecommendation);
    
    func userTappedOnAdChoicesIcon(_ url:URL);
    
    func userTappedOnOutbrainLogo();
}

class OutbrainFooterView: UIView, UITableViewDataSource, UITableViewDelegate {
    static let nibName = "OutbrainFooterView"
    let kFooterHeightOffset:CGFloat = 10.0
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    var recs:[OBRecommendation] = [OBRecommendation]()
    var delegate:OutbrainFooterViewDelegate?
    var outbrainHeaderView:OutbrainHeaderView?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        let nibName = "OBRecCell"
        let nib = UINib(nibName: nibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "OBRecCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.outbrainHeaderView = OutbrainHeaderView.loadHeaderFromNib()
        self.outbrainHeaderView?.outbrainLogoButton.imageView?.contentMode = .scaleAspectFit
        self.outbrainHeaderView?.autoresizingMask = UIViewAutoresizing()
        self.outbrainHeaderView?.outbrainLogoButton.addTarget(self, action: #selector(OutbrainFooterView.outbrainLogoClicked(_:)), for: .touchUpInside)

        
    }
    
    func updateHeightOnView() {
        if let delegate = self.delegate {
            self.outbrainHeaderView!.frame.size.height = 35.0
            self.tableView.tableHeaderView = self.outbrainHeaderView
            
            OBHelper.delay(0.4, closure: {
                self.frame.size.height = self.tableView.contentSize.height + self.kFooterHeightOffset
                delegate.heightHasChanged()
            })
        }
    }
    
    @objc func outbrainLogoClicked(_ sender: UIButton!) {
        if let delegate = self.delegate {
            delegate.userTappedOnOutbrainLogo()
        }
    }
}


extension OutbrainFooterView {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recs.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OBRecCell", for: indexPath) as! OBRecCell
        
        let rec = self.recs[indexPath.row]
        
        cell.recTitle.text = rec.content
        cell.recSource.text = rec.source
        
        // Handle RTB
        if rec.shouldDisplayDisclosureIcon() {
            cell.adChoicesButton.tag = indexPath.row
            cell.adChoicesButton.isHidden = false
            if let adChoicesImageURL = rec.disclosure?.imageUrl {
                Alamofire.request(adChoicesImageURL).responseImage { response in
                    if let image = response.result.value {
                        cell.adChoicesButton.setImage(image, for: .normal)
                    }
                }
            }
            cell.adChoicesButton.addTarget(self, action: #selector(self.adChoicesClicked), for: .touchUpInside)

        }
        else {
            cell.adChoicesButton.isHidden = true
        }
        
        if let imageUrl = rec.image?.url {
            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    cell.recImageView.image = image
                }
            }
        }
        
        // If this is the last cell we want let the delegate know about the new height
        if (indexPath.row == (self.recs.count - 1)) {
            self.updateHeightOnView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rec = self.recs[indexPath.row]
        self.delegate?.userTappedRecommendation(rec)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func adChoicesClicked(sender: UIButton) {
        // your code goes here
        let rec = self.recs[sender.tag]
        if let clickURL = rec.disclosure?.clickUrl {
            self.delegate?.userTappedOnAdChoicesIcon(clickURL)
        }
    }
}


protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    static func loadFromNib() -> Self {
        return OutbrainFooterView.nib.instantiate(withOwner: self, options: nil).first as! Self
    }
    
}
