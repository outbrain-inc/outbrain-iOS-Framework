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

@interface SFWidget() <SFMessageHandlerDelegate>

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

-(void) configureWithDelegate:(id<SFWidgetDelegate>)delegate url:(NSString *)url widgetId:(NSString *)widgetId installationKey:(NSString *)installationKey userId:(NSString *)userId {
    self.delegate = delegate;
    self.url = url;
    self.widgetId = widgetId;
    self.installationKey = installationKey;
    self.userId = userId;
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

#pragma mark - SFWidgetMessageHandlerDelegate
- (void)didHeightChanged:(NSInteger)height {
    self.currentHeight = height;
    self.frame = CGRectMake(0, 0, self.frame.size.width, (CGFloat)height);
    [self setNeedsLayout];
    [self.delegate didChangeHeight];
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

@end
