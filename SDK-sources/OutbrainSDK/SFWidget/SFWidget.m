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

@interface SFWidget()

@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, assign) NSInteger currentHeight;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL inTransition;

// widget properties
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *widgetId;
@property (nonatomic, strong) NSString *installationKey;
@property (nonatomic, strong) NSString *userId;

//
@property (nonatomic, weak) id<SFWidgetDelegate> delegate;

@property (nonatomic, strong) SFWidgetMessageHandler *messageHandler;

@end

@implementation SFWidget


#pragma mark - Init Methods
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //TODO messageHandler = SFScriptMessageHandler()
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //TODO messageHandler = SFScriptMessageHandler()
    }
    return self;
}

#pragma mark - Public Methods

-(void) configureWithDelegate:(id<SFWidgetDelegate>)delegate url:(NSString *)url widgetId:(NSString *)widgetId installationKey:(NSString *)installationKey userId:(NSString *)userId {
    self.delegate = delegate;
    self.url = url;
    self.widgetId = widgetId;
    self.installationKey = installationKey;
    self.userId = userId;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.inTransition = YES;
    
    // TODO self.evaluateHeightScript(timeout: 300)
    
    // run after transition finished
    // https://stackoverflow.com/questions/26943808/ios-how-to-run-a-function-after-device-has-rotated-swift
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.inTransition = NO;
    }];
}

- (CGFloat) getCurrentHeight {
    return self.currentHeight;
}

#pragma mark - UITableView
-(void) willDisplaySFWidgetTableCell:(SFWidgetTableCell *)cell {
    //TODO
}

#pragma mark - UICollectionView
-(void) willDisplaySFWidgetCollectionCell:(SFWidgetCollectionCell *)cell {
    //TODO
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
    [self addSubview:self.webview];
    [SFUtils addConstraintsToFillParent:self.webview];
    [self.webview setNeedsLayout];
    
    NSURL *widgetURL = [self getSmartfeedWidgetUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:widgetURL];
    [self.webview loadRequest:urlRequest];
    [self.webview setNeedsLayout];
}

- (NSURL *) getSmartfeedWidgetUrl {
    if (self.url == nil || self.widgetId == nil || self.installationKey == nil) {
        NSLog(@"Error in getSmartfeedUrl() - missing mandatory params");
        return nil;
    }
    NSString *baseUrl = @"https://widgets.outbrain.com/reactNativeBridge/index.html";
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:baseUrl];
    NSMutableArray * newQueryItems = [NSMutableArray arrayWithCapacity:[components.queryItems count] + 1];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"permalink" value: self.url]];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"widgetId" value: self.widgetId]];
    [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"installationKey" value: self.installationKey]];
    
    if (self.userId) {
        [newQueryItems addObject: [[NSURLQueryItem alloc] initWithName:@"userId" value: self.userId]];
    }
    [components setQueryItems:newQueryItems];
    return components.URL;
}

@end
