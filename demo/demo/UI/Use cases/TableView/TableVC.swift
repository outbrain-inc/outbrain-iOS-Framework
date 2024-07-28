//
//  TableVC.swift
//  SFWebView-Dev
//
//  Created by Oded Regev on 21/06/2021.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import OutbrainSDK

class TableVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView
    private let imageHeaderCellReuseIdentifier = "imageHeaderCell"
    private let textHeaderCellReuseIdentifier = "textHeaderCell"
    private let contentCellReuseIdentifier = "contentHeaderCell"
    private var sfWidget: SFWidget!
    private let originalArticleItemsCount = 6
//    private let READ_MORE_FLAG = false
    private let OUTBRAIN_SECTION_INDEX = 1
    private let paramsViewModel: ParamsViewModel
    
    init(paramsViewModel: ParamsViewModel) {
        self.tableView = UITableView()
        self.paramsViewModel = paramsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        
        sfWidget.configure(
            with: self,
            url: paramsViewModel.articleURL,
            widgetId: paramsViewModel.bridgeWidgetId,
            installationKey: "NANOWDGT01"
        )
    }
    
    private func setupTableView() {
        tableView.register(
            .init(
                nibName: "ImageHeaderCell",
                bundle: nil
            ),
            forCellReuseIdentifier: imageHeaderCellReuseIdentifier
        )
        
        tableView.register(
            .init(
                nibName: "TextHeaderCell",
                bundle: nil
            ),
            forCellReuseIdentifier: textHeaderCellReuseIdentifier
        )
        
        tableView.register(
            .init(
                nibName: "ContentHeaderCell",
                bundle: nil
            ),
            forCellReuseIdentifier: contentCellReuseIdentifier
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SFWidgetTableCell.self, forCellReuseIdentifier: "SFWidgetCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sfWidget.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: UITableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == OUTBRAIN_SECTION_INDEX) {
            return 1
        }
        else {
            return originalArticleItemsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if (indexPath.section == OUTBRAIN_SECTION_INDEX) {
            if let sfWidgetCell = self.tableView.dequeueReusableCell(withIdentifier: "SFWidgetCell") as? SFWidgetTableCell {
                return sfWidgetCell
            }
        }
        switch indexPath.row {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: imageHeaderCellReuseIdentifier) as UITableViewCell?
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: textHeaderCellReuseIdentifier) as UITableViewCell?
        default:
            cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellReuseIdentifier) as UITableViewCell?
            break;
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == OUTBRAIN_SECTION_INDEX) {
            if let sfWidgetCell = cell as? SFWidgetTableCell {
                self.sfWidget.willDisplay(sfWidgetCell)
            }
            return
        }
        switch indexPath.row {
        case 0:
            break
        case 1:
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 30.0 : 20.0
                articleCell.headerLabel.font = UIFont(name: articleCell.headerLabel.font!.fontName, size: CGFloat(fontSize))
                articleCell.headerLabel.textColor = UIColor.black
            }
            break
        default:
            if let articleCell = cell as? AppArticleTableViewCell {
                articleCell.backgroundColor = UIColor.white
                let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
                articleCell.contentTextView.font = UIFont(name: articleCell.contentTextView.font!.fontName, size: CGFloat(fontSize))
                articleCell.contentTextView.textColor = UIColor.black
            }
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == OUTBRAIN_SECTION_INDEX) {
            return self.sfWidget.getCurrentHeight();
        }
        switch indexPath.row {
        case 0:
            return UIDevice.current.userInterfaceIdiom == .pad ? 400 : 250;
        case 1:
            return UIDevice.current.userInterfaceIdiom == .pad ? 150 : UITableView.automaticDimension;
        default:
            return UIDevice.current.userInterfaceIdiom == .pad ? 200 : UITableView.automaticDimension;
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sfWidget.scrollViewDidScroll(scrollView)
    }
}


// MARK: SFWidgetDelegate
extension TableVC: SFWidgetDelegate {
    func didChangeHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func onOrganicRecClick(_ url: URL) {
        // handle click on organic url
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func onRecClick(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }
}
