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
    // use SDK_MAIN_1 to test "trending in category"
    // static var widgetID = "SFD_MAIN_5"
    // static var widgetID = "SFD_MAIN_4"
    static var baseURL = "http://mobile-demo.outbrain.com/2014/01/26/4-steps-to-re-launching-your-company-blog"
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var outbrainVideoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        performSegue(withIdentifier: "showCollectionVC", sender: nil)
        //performSegue(withIdentifier: "showTableVC", sender: nil)
        //performSegue(withIdentifier: "showVideoVC", sender: nil)
        //performSegue(withIdentifier: "showTableMidPageVC", sender: nil)
        //performSegue(withIdentifier: "showCollectionMidPageVC", sender: nil)
        //performSegue(withIdentifier: "showStackViewVC", sender: nil)
        //performSegue(withIdentifier: "showTableReadMoreModuleVC", sender: nil)
        //performSegue(withIdentifier: "showCollectionReadMoreModuleVC", sender: nil)
    }
}

