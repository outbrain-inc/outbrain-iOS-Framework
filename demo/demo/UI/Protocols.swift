//
//  Protocols.swift
//  demo
//
//  Created by Leonid Lemesev on 07/10/2024.
//

import UIKit


protocol UIKitContentPage: UIViewController {
    
    init(
        navigationViewModel: NavigationViewModel,
        paramsViewModel: ParamsViewModel,
        params: [String: Bool]?
    )
}
