//
//  GoogleBannerView.swift
//  OutbrainSDK
//
//  Created by oded regev on 26/01/2025.
//
import GoogleMobileAds
import UIKit
import OutbrainSDK

enum GoogleAdEvents: String {
    case adLoaded = "onNativeGoogleAdsAdLoaded"
    case adFailed = "onNativeGoogleAdsLoadFailed"
    case adImpression = "onNativeGoogleAdsAdImpression"
    case adClick = "onNativeGoogleAdsAdClick"
    
    static let adHeightKey = "height"
    static let adWidgetIdxKey = "widgetIdx"
    static let adErrorReasonKey = "reason"
}

@objc(GoogleBannerView)
class GoogleBannerView: UIView, GoogleBannerViewProtocol {
    var bannerView: GADBannerView!
    private var bannerHeightConstraint: NSLayoutConstraint?
    weak var rootViewController: UIViewController?
    weak var delegate: GoogleBannerViewDelegate?
    private var widgetIdx: Int = 0
    
    static func forceLoad() {
        print("GoogleBannerView loaded")
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false;
        GADMobileAds.sharedInstance().start(completionHandler: { _ in
            print("Google Ads init complete");
        });
    }
    
    // MARK: - Setup Methods
    
    /// Called to configure the view's initial setup, such as setting background color or adding subviews.
    func tryToLoadGoogleAds(adTag: String, yOffset: CGFloat, adWidth: CGFloat, widgetIdx: Int) {
        self.widgetIdx = widgetIdx
        let adaptiveSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(adWidth, adWidth/1.2)
        print("GoogleBannerView: adaptiveSize: \(adaptiveSize), width: \(adWidth)")
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = adTag
        bannerView.rootViewController = rootViewController
        addBannerViewToView(bannerView)
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)
        
        // Add initial constraints, including a placeholder height
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: self.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    
}

extension GoogleBannerView : GADBannerViewDelegate {
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully: size: \(bannerView.frame.size)")
        layoutIfNeeded()
        
        // report event
        let eventPayload: [String : Any] = [
            GoogleAdEvents.adHeightKey: bannerView.frame.size.height,
            GoogleAdEvents.adWidgetIdxKey: widgetIdx
        ]
        delegate?.reportGoogleAdEvent(event: GoogleAdEvents.adLoaded.rawValue, payload: eventPayload)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Failed to load banner: \(error)")
        // report event
        let eventPayload: [String : Any] = [
            GoogleAdEvents.adErrorReasonKey: error.localizedDescription,
            GoogleAdEvents.adWidgetIdxKey: widgetIdx
        ]
        delegate?.reportGoogleAdEvent(event: GoogleAdEvents.adFailed.rawValue, payload: eventPayload)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
        // report event
        let eventPayload: [String : Any] = [
            GoogleAdEvents.adWidgetIdxKey: widgetIdx
        ]
        delegate?.reportGoogleAdEvent(event: GoogleAdEvents.adImpression.rawValue, payload: eventPayload)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordClick")
        let eventPayload: [String : Any] = [
            GoogleAdEvents.adWidgetIdxKey: widgetIdx
        ]
        delegate?.reportGoogleAdEvent(event: GoogleAdEvents.adClick.rawValue, payload: eventPayload)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen - click")
    }

}
