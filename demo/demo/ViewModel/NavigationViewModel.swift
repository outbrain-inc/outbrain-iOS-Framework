//
//  NavigationViewModel.swift
//  demo
//
//  Created by Leonid Lemesev on 09/07/2024.
//

import Foundation
import SwiftUI


class NavigationViewModel: ObservableObject, Identifiable {
    
    var id = UUID()
    
    enum Path: Hashable {
        case useCases
        case tableView
        case collectionView
        case scrollView
        case swiftUI
        case regular
        case readMore
    }
    
    @Published var paths = NavigationPath()
    
    lazy var paramsViewModel: ParamsViewModel = { .init() }()
    
    
    
    func push(_ path: Path) {
        DispatchQueue.main.async { [weak self] in
            self?.paths.append(path)
        }
    }
    
    func popLast() {
        DispatchQueue.main.async { [weak self] in
            self?.paths.removeLast()
        }
    }
}
