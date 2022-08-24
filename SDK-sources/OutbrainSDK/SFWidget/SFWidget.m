//
//  SFWidget.m
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import "SFWidget.h"
#import "SFWidgetMessageHandler.h"
#import "SFUtils.h"
#import "OBUtils.h"
#import "GDPRUtils.h"
#import "OBErrorReporting.h"
#import "OBAppleAdIdUtil.h"

@interface SFWidget() <SFMessageHandlerDelegate, WKUIDelegate>

@property (nonatomic, assign) NSInteger currentHeight;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL inTransition;

// widget properties
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *widgetId;
@property (nonatomic, strong) NSString *installationKey;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSInteger widgetIndex;
@property (nonatomic, strong) NSString *tParam;
@property (nonatomic, assign) BOOL darkMode;

//
@property (nonatomic, weak) id<SFWidgetDelegate> delegate;

@property (nonatomic, strong) SFWidgetMessageHandler *messageHandler;

@property (nonatomic, strong) WKWebView *hiddenWebView;

@end


NSString * const SFWIDGET_T_PARAM_NOTIFICATION     =   @"SFWidget_T_Param_Ready";


@implementation SFWidget

#pragma mark - Init Methods
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.messageHandler = [[SFWidgetMessageHandler alloc] init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.messageHandler = [[SFWidgetMessageHandler alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

-(void) configureWithDelegate:(id<SFWidgetDelegate>)delegate url:(NSString *)url widgetId:(NSString *)widgetId installationKey:(NSString *)installationKey {
    [self configureWithDelegate:delegate url:url widgetId:widgetId widgetIndex:0 installationKey:installationKey userId:nil darkMode:NO];
}

-(void) configureWithDelegate:(id<SFWidgetDelegate>)delegate url:(NSString *)url widgetId:(NSString *)widgetId widgetIndex:(NSInteger)widgetIndex installationKey:(NSString *)installationKey userId:(NSString *)userId darkMode:(BOOL)darkMode {
    self.delegate = delegate;
    self.url = url;
    self.widgetId = widgetId;
    self.widgetIndex = widgetIndex;
    self.installationKey = installationKey;
    self.userId = userId;
    self.darkMode = darkMode;
    
    if (userId == nil)
    {
        if ([[OBUtils deviceModel] isEqualToString:@"Simulator"]) {
            self.userId = @"F22700D5-1D49-42CC-A183-F3676526035F"; // dev hack to test Videos
        }
        else if (![OBAppleAdIdUtil isOptedOut] && [OBAppleAdIdUtil getAdvertiserId]) {
            self.userId = [OBAppleAdIdUtil getAdvertiserId];
        }
    }
    
    self.messageHandler.delegate = self;
    [self configureSFWidget];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.inTransition = YES;
    
    // run after transition finished
    // https://stackoverflow.com/questions/26943808/ios-how-to-run-a-function-after-device-has-rotated-swift
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self evaluateHeightScript:300];
        self.inTransition = NO;
    }];
}

- (CGFloat) getCurrentHeight {
    return self.currentHeight;
}

#pragma mark - UITableView
-(void) willDisplaySFWidgetTableCell:(SFWidgetTableCell *)cell {
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:self];
    [SFUtils addConstraintsToFillParent:self];
}

#pragma mark - UICollectionView
-(void) willDisplaySFWidgetCollectionCell:(SFWidgetCollectionCell *)cell {
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:self];
    [SFUtils addConstraintsToFillParent:self];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    @try  {
        [self handleViewability:scrollView];
    } @catch (NSException *exception) {
        NSLog(@"Exception in SFWidget - scrollViewDidScroll() - %@",exception.name);
        NSLog(@"Reason: %@ ",exception.reason);
        NSString *errorMsg = [NSString stringWithFormat:@"Exception in SFWidget - scrollViewDidScroll() - %@ - reason: %@", exception.name, exception.reason];
        [[OBErrorReporting sharedInstance] reportErrorToServer:errorMsg];
    }
    
    if (self.isLoading || self.inTransition || self.currentHeight <= 1000) {
        return;
    }
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat diffFromBottom = (scrollView.contentSize.height - scrollView.frame.size.height) - contentOffsetY;
    if (diffFromBottom < 1000) {
        [self loadMore];
    }
}

#pragma mark - Private Methods
-(void) loadMore {
    self.isLoading = YES;
    [self evaluateLoadMore];
    
}

-(void) handleViewability:(UIView *)containerView {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect viewFrame = [self convertRect:self.bounds toView:nil];
    CGRect intersection = CGRectIntersection(viewFrame, containerView.frame);
    
    NSInteger intersactionHeight = (NSInteger) lroundf(intersection.size.height * scale);
    
    CGFloat containerViewHeight = containerView.frame.size.height * scale;
    NSInteger roundedContainerViewHeight = (NSInteger) lroundf(containerViewHeight);
    
    NSInteger webViewHeight = (NSInteger) lroundf(viewFrame.size.height * scale);
    
    double distanceToContainerTop = (CGRectGetMinY(containerView.frame) - CGRectGetMinY(viewFrame)) * scale;
    
    double distanceToContainerBottom = (CGRectGetMaxY(containerView.frame) - CGRectGetMinY(viewFrame)) * scale;
    
    BOOL isViewVisible = distanceToContainerBottom > 0 && containerViewHeight != distanceToContainerBottom && intersactionHeight != 0;
    
    NSInteger visibleFrom;
    NSInteger visibleTo;
    
    if (isViewVisible) {
        // webview on screen
        if (distanceToContainerTop < 0) {
            // top
            visibleFrom = 0;
            visibleTo = distanceToContainerBottom;
        } else if (intersactionHeight < containerViewHeight) {
            // bottom
            visibleFrom = webViewHeight - intersactionHeight;
            visibleTo = webViewHeight;
        } else {
            // full
            visibleFrom = distanceToContainerTop;
            visibleTo = distanceToContainerTop + roundedContainerViewHeight;
        }
        
        [self eveluateViewabilityScriptFrom:visibleFrom to:visibleTo];
    }
}

-(void) eveluateViewabilityScriptFrom:(NSInteger)from to:(NSInteger)to {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect viewFrame = [self convertRect:self.bounds toView:nil];
    NSInteger webViewHeight = (NSInteger) lroundf(viewFrame.size.height * scale);
    NSInteger webViewWidth = (NSInteger) lroundf(viewFrame.size.width * scale);
        
    NSString *script = [NSString stringWithFormat:
                            @"OBBridge.viewHandler.setViewData(%ld, %ld, %ld, %ld)",
                        (long)webViewWidth, // totalWidth
                        (long)webViewHeight, // totalHeight
                        (long)from,
                        (long)to
    ];
    
    [self.webview evaluateJavaScript:script completionHandler:nil];
}

-(void) evaluateHeightScript:(NSInteger) timeout {
    if (self.webview == nil) {
        return;
    }
    NSString *script = [NSString stringWithFormat:@""
                        @"setTimeout(function() {"
                        @"  let result = {};"
                        @"  let height = document.body.scrollHeight;"
                        @"  result[\"height\"] = height;"
                        @"  window['ReactNativeWebView'].postMessage(JSON.stringify(result))"
                        @"}, %ld);", (long)timeout];
    
    [self.webview evaluateJavaScript:script completionHandler:nil];
}

-(void) evaluateLoadMore {
    NSLog(@"loading more --->");
    [self.webview evaluateJavaScript:@"OBR.viewHandler.loadMore(); true;" completionHandler:nil];
    [self evaluateHeightScript:500];
}


-(void) configureSFWidget {
    if (self.webview != nil) {
        return;
    }
    WKPreferences *preferences = [[WKPreferences alloc] init];
    WKWebViewConfiguration *webviewConf = [[WKWebViewConfiguration alloc] init];
    NSString *jsInitScript = [NSString stringWithFormat:@""
                              @"window.ReactNativeWebView = {"
                              @"    postMessage: function (data) {"
                              @"        window.webkit.messageHandlers.ReactNativeWebView.postMessage(String(data));"
                              @"    }"
                              @"}"
                              ];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:jsInitScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self.messageHandler name:@"ReactNativeWebView"];
    [controller addUserScript:script];
    preferences.javaScriptEnabled = YES;
    webviewConf.userContentController = controller;
    webviewConf.allowsInlineMediaPlayback = YES;
    webviewConf.preferences = preferences;
    
    self.webview = [[WKWebView alloc] initWithFrame:self.frame configuration:webviewConf];
    self.webview.scrollView.scrollEnabled = NO;
    [self.webview setOpaque:NO];
    self.webview.UIDelegate = self;
    [self addSubview:self.webview];
    [SFUtils addConstraintsToFillParent:self.webview];
    [self.webview setNeedsLayout];
    
    if (self.widgetIndex > 0) {
        NSLog(@"differ fetching until we'll have the \"t\" param ready");
        [[NSNotificationCenter defaultCenter] addObserver:self
                      selector:@selector(receiveTParamNotification:)
                      name:SFWIDGET_T_PARAM_NOTIFICATION
                      object:nil];
        return;
    }
    else {
        [self initialLoadUrl];
    }
}


-(void) reportPageViewOnTheSameWidget {
    NSLog(@"Outbrain SDK reportPageViewOnTheSameWidget() is called");
    WKWebViewConfiguration *webviewConf = [[WKWebViewConfiguration alloc] init];
    self.hiddenWebView = [[WKWebView alloc] initWithFrame:self.frame configuration:webviewConf];
    NSURL *widgetURL = [self getSmartfeedWidgetUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:widgetURL];
    [self.hiddenWebView loadRequest:urlRequest];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveTParamNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:SFWIDGET_T_PARAM_NOTIFICATION]) {
        NSLog (@"Successfully received SFWIDGET_T_PARAM_NOTIFICATION");
        self.tParam = [notification.userInfo valueForKey:@"t"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initialLoadUrl];
        });
    }
}

- (void) initialLoadUrl {
    NSURL *widgetURL = [self getSmartfeedWidgetUrl];
    NSLog(@"widgetURL: %@", widgetURL);
    
    [OBErrorReporting sharedInstance].odbRequestUrlParamValue = self.url;
    [OBErrorReporting sharedInstance].widgetId = self.widgetId;
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:widgetURL];
    [self.webview loadRequest:urlRequest];
    [self.webview setNeedsLayout];
}

- (NSURL *) getSmartfeedWidgetUrl {
    if (self.url == nil || self.widgetId == nil || self.installationKey == nil) {
        NSLog(@"Error in getSmartfeedUrl() - missing mandatory params");
        return nil;
    }
    NSString *appNameStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *widgetIndex = [NSString stringWithFormat:@"%d", self.widgetIndex];
    NSString *baseUrl = @"https://widgets.outbrain.com/reactNativeBridge/index.html";
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:baseUrl];
    
    NSMutableArray * newQueryItems = [NSMutableArray arrayWithCapacity:[components.queryItems count] + 1];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"permalink" value: self.url]];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"widgetId" value: self.widgetId]];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"idx" value: widgetIndex]];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"installationKey" value: self.installationKey]];
    if (self.tParam) {
        [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"t" value: self.tParam]];
    }
    if (self.darkMode) {
        [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"darkMode" value: @"true"]];
    }
    
    // GDPR v1
    NSString *consentString;
    if (GDPRUtils.sharedInstance.cmpPresent) {
        consentString = GDPRUtils.sharedInstance.gdprV1ConsentString;
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"cnsnt" value: consentString]];
    }
    // GDPR v2
    if (GDPRUtils.sharedInstance.gdprV2ConsentString) {
        consentString = GDPRUtils.sharedInstance.gdprV2ConsentString;
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"cnsntv2" value: consentString]];
    }
    // CCPA
    if (GDPRUtils.sharedInstance.ccpaPrivacyString) {
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"ccpa" value: GDPRUtils.sharedInstance.ccpaPrivacyString]];
    }
    
    // Video Params
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"platform" value: @"iOS"]];
    [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"sdkVersion" value: OB_SDK_VERSION]];
    [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"inApp" value: @"true"]];
    [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appBundle" value: bundleIdentifier]];
    [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appName" value: appNameStr]];
    
    if (self.userId) {
        [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"userId" value: self.userId]];
    }
    
    [newQueryItems addObject:[NSURLQueryItem queryItemWithName:@"viewData" value: @"enabled"]];
    
    [components setQueryItems:newQueryItems];
    return components.URL;
}

#pragma mark - SFWidgetMessageHandlerDelegate
- (void)didHeightChanged:(NSInteger)height {
    self.currentHeight = height;
    self.frame = CGRectMake(0, 0, self.frame.size.width, (CGFloat)height);
    [self setNeedsLayout];
    if ([self.delegate respondsToSelector:@selector(didChangeHeight:)]) {
        [self.delegate didChangeHeight:self.currentHeight];
    }
    if ([self.delegate respondsToSelector:@selector(didChangeHeight)]) {
        [self.delegate didChangeHeight];
    }
    
    if (self.isLoading) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.isLoading = NO;
        });
    }
}

- (void)didClickOnRec:(NSString *)url {
    NSURL *recURL = [NSURL URLWithString:url];
    if (recURL != nil) {
        [self.delegate onRecClick: recURL];
    }
}

- (void)didClickOnOrganicRec:(NSString *)url orgUrl:(NSString *)orgUrl {
    NSURL *recURL = [NSURL URLWithString:url];
    NSURL *recOriginalURL = [NSURL URLWithString:orgUrl];
    if (recURL == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onOrganicRecClick:)]) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
        NSMutableArray * newQueryItems = [components.queryItems mutableCopy];
        [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"noRedirect" value: @"true"]];
        [components setQueryItems:newQueryItems];
        NSURL *trafficURL = components.URL;
        if (trafficURL) {
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:trafficURL
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
            {
                if (error) {
                    NSLog(@"Error reporting organic click: %@, error: %@", trafficURL, error);
                }
                else {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    NSLog(@"Report organic click response code: %ld", (long)statusCode);
                }
                
            }];
            [dataTask resume];
        }
        [self.delegate onOrganicRecClick:recOriginalURL];
    }
    else {
        [self.delegate onRecClick:recURL];
    }
}

- (void) widgetRendered {
    // NSLog(@"SFWidget - widgetRendered");
    if ([self.delegate respondsToSelector:@selector(widgetRendered)]) {
        [self.delegate widgetRendered];
    }
}

#pragma mark - WKUIDelegate
-(WKWebView *) webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        if (self.delegate != nil && navigationAction.request.URL != nil) {
            [self.delegate onRecClick: navigationAction.request.URL];
        }
    }
    return nil;
}



@end
