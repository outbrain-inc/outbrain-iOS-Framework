
//
//  ArticleCollectionViewController.swift
//  ios-SmartFeed
//
//  Created by Oded Regev on 2/4/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import SafariServices
import OutbrainSDK

class OBVideoWidgetViewController: UICollectionViewController {
    
    private let imageHeaderCellReuseIdentifier = "imageHeaderCollectionCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCollectionCell"
    private let contentCellReuseIdentifier = "contentCollectionCell"
    private let outbrainRecCellReuseIdentifier = "outbrainRecCollectionCell"
    private var refresher: UIRefreshControl!
    private var outbrainVideoWidget: OBVideoWidget? = nil
    private let originalArticleItemsCount = 6
    private let paramsViewModel: ParamsViewModel

    
    init(paramsViewModel: ParamsViewModel) {
        self.paramsViewModel = paramsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.blue
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    @objc func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.stopRefresher()
            self.outbrainVideoWidget = nil
            self.collectionView?.reloadData()
        })
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


// MARK: - UICollectionViewDataSource
extension OBVideoWidgetViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return originalArticleItemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UICollectionViewCell?
        
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageHeaderCellReuseIdentifier,
                                                      for: indexPath)
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: textHeaderCellReuseIdentifier,
                                                      for: indexPath)
            
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: outbrainRecCellReuseIdentifier,
                                                      for: indexPath)
        case 2,4,5:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellReuseIdentifier,
                                                      for: indexPath)
        default:
            break
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // App Developer should configure the app cells here..
        if (indexPath.row == 1) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
            }
        }
        
        if (indexPath.row == 3) {
            if let outbrainContainerView = cell.viewWithTag(111) {
                if (self.outbrainVideoWidget == nil) {
                    let obRequest = OBRequest(
                        url: paramsViewModel.articleURL,
                        widgetID:  paramsViewModel.widgetId
                    )
                    self.outbrainVideoWidget = OBVideoWidget(request: obRequest, containerView: outbrainContainerView)
                    self.outbrainVideoWidget?.delegate = self
                    self.outbrainVideoWidget?.start()
                }
            }
        }
        
        if (indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5) {
            if let articleCell = cell as? AppArticleCollectionViewCell {
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
            }
        }
    }
}

extension OBVideoWidgetViewController : OBVideoWidgetDelegate {
    func userTapped(on rec: OBRecommendation) {
        print("You tapped rec \(String(describing: rec.content)).")
        guard let url = Outbrain.getUrl(rec) else {
            print("Error: no url for rec.")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTapped(onAdChoicesIcon url: URL) {
        print("You tapped onAdChoicesIcon")
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTapped(onVideoRec url: URL) {
        print("You tapped on video rec")
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func userTappedOnOutbrainLabeling() {
        print("You tapped on Outbrain Labeling")
        let url = Outbrain.getAboutURL()
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    
}

extension OBVideoWidgetViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.size.width
        
        switch indexPath.row {
        case 0:
            return CGSize(width: width, height: 0.5625*width)
        case 1:
            return CGSize(width: width, height: 0.35*width)
        case 3:
            return CGSize(width: width, height: 300.0)
        case 2,4,5:
            return CGSize(width: width, height: 200.0)
        default:
            break
        }
        return CGSize(width: width, height: 200.0)
    }
}


