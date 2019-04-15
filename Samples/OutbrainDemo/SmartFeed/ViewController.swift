//
//  ViewController.swift
//  ios-SmartFeed
//
//  Created by oded regev on 1/30/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import OutbrainSDK


struct OBConf {
    static var widgetID = UIDevice.current.userInterfaceIdiom == .pad ? "SFD_MAIN_3" : "SFD_MAIN_2"
    // static let widgetID = "SFD_MAIN_5"
    // static let widgetID = "SFD_MAIN_4"
    static var baseURL = "http://mobile-demo.outbrain.com/2013/12/15/test-page-2"
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var outbrainVideoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        performSegue(withIdentifier: "showCollectionVC", sender: nil)
        //performSegue(withIdentifier: "showTableVC", sender: nil)
        //performSegue(withIdentifier: "showVideoVC", sender: nil)
    }
}

