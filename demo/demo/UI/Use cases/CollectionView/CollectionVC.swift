//
//  CollectionVC.swift
//  OBSDKiOS-SFWidget
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import SafariServices
import OutbrainSDK

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIKitContentPage {
    
    private var collectionView: UICollectionView
    private let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    private let contentCellReuseIdentifier = "contentCollectionCell"
    private var sfWidget: SFWidget!
    private let originalArticleItemsCount = 5
    private let paramsViewModel: ParamsViewModel
    private let navigationViewModel: NavigationViewModel
    
    
    required init(navigationViewModel: NavigationViewModel, params: [String : Bool]?) {
        collectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationViewModel = navigationViewModel
        self.paramsViewModel = navigationViewModel.paramsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        
        setupCollectionView()
        sfWidget.enableEvents()
        sfWidget.configure(
            with: self,
            url: paramsViewModel.articleURL,
            widgetId: paramsViewModel.bridgeWidgetId,
            widgetIndex: 0,
            installationKey: "NANOWDGT01",
            userId: nil,
            darkMode: paramsViewModel.darkMode
        )
    }
    
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(
                nibName: "ArticleContentCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: contentCellReuseIdentifier
        )
        collectionView.register(
            UINib(nibName: "ImageHeaderCollectionViewCell",
                  bundle: nil
                 ),
            forCellWithReuseIdentifier: imageHeaderCellReuseIdentifier
        )
        collectionView.register(
            UINib(nibName: "ArticleHeaderCollectionViewCell",
                  bundle: nil),
            forCellWithReuseIdentifier: textHeaderCellReuseIdentifier
        )
        collectionView.register(SFWidgetCollectionCell.self, forCellWithReuseIdentifier: "SFWidgetCell")
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        self.sfWidget.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: textHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case 2,3,4:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellReuseIdentifier,
                                                      for: indexPath)
        default:
            if let sfWidgetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFWidgetCell", for: indexPath) as? SFWidgetCollectionCell {
                cell = sfWidgetCell
            }
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            if let articleCell = cell as? ArticleHeaderCollectionViewCell {
                articleCell.backgroundColor = UIColor.white;
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = UIColor.black;
                
            }
            break
        case 2, 3, 4:
            if let articleCell = cell as? ArticleContentCollectionViewCell {
                articleCell.backgroundColor = UIColor.white;
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = UIColor.black;
            }
            break
        default:
            if let sfWidgetCell = cell as? SFWidgetCollectionCell {
                sfWidget.willDisplay(sfWidgetCell)
            }
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return originalArticleItemsCount + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.size.width
        
        switch indexPath.row {
            case 0:
                return CGSize(width: width, height: 0.5625*width)
            case 1:
                return CGSize(width: width, height: 0.35*width)
            case 2,3,4:
                return CGSize(width: width, height: 200.0)
            default:
                break
        }
        
        return CGSize(width: width, height: sfWidget.getCurrentHeight())
    }
}


// MARK: SFWidgetDelegate
extension CollectionVC: SFWidgetDelegate {
    
    func didChangeHeight(_ newHeight: CGFloat) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func onOrganicRecClick(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationViewModel.push(.collectionView)
        }
    }
    
    func onRecClick(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func widgetEvent(_ eventName: String, additionalData: [String : Any]) {
        print("App received widgetEvent: **\(eventName)** with data: \(additionalData)")
    }
}
