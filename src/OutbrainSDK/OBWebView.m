//
//  OBWebView.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBWebView.h"
#import "CustomWebViewManager.h"

@interface OBWebView()

@property (nonatomic, weak) id<UIWebViewDelegate> externalDelegate;

@property (nonatomic, strong) NSString *paidOutbrainParams;
@property (nonatomic, strong) NSString *paidOutbrainUrl;

@property (nonatomic, assign) BOOL alreadyReportedOnPercentLoad;
@property (nonatomic, assign) float percentLoadThreshold;

@property (nonatomic, strong) NSDate *loadStartDate;


@end




@implementation OBWebView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [super setDelegate:self];
        
        // TODO implement progress monitoring
        
        
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



@end
