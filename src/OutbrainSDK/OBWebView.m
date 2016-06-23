//
//  OBWebView.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBWebView.h"
#import "CustomWebViewManager.h"
#import "NJKWebViewProgress.h"

@interface OBWebView()

@property (nonatomic, weak) id<UIWebViewDelegate> externalDelegate;

@property (nonatomic, strong) NSString *paidOutbrainParams;
@property (nonatomic, strong) NSString *paidOutbrainUrl;

@property (nonatomic, assign) BOOL alreadyReportedOnPercentLoad;
@property (nonatomic, assign) float percentLoadThreshold;

@property (nonatomic, strong) NSDate *loadStartDate;

@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@end




@implementation OBWebView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.progressProxy = [[NJKWebViewProgress alloc] init];
        
        [super setDelegate:self.progressProxy]; // Pass Webview delegate calls to progressProxy
        
        self.progressProxy.webViewProxyDelegate = self; // progressProxy will pass UIWebViewDelegate delegate calls back to original delegate after handling the calls itself.
        
        self.progressProxy.progressDelegate = (id<NJKWebViewProgressDelegate>)self; // Receive the progress status from the progressProxy
    
        
        self.percentLoadThreshold = [[CustomWebViewManager sharedManager] paidRecsLoadPercentsThreshold];
        
    }
    return self;
}

- (void)dealloc
{
    [super setDelegate:nil];
}

-(void) setDelegate:(id<UIWebViewDelegate>)delegate {
    self.externalDelegate = delegate;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    NSLog(@"** progress: %f **", progress);
}

@end
