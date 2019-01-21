//
//  OBVideoWidget.m
//  OutbrainSDK
//
//  Created by oded regev on 19/12/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "OBVideoWidget.h"
#import "SFUtils.h"
#import "OBViewabilityService.h"
#import "SFVideoCollectionViewCell.h"
#import "SFCollectionViewManager.h"

@interface OBVideoWidget() <SFClickListener, WKUIDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) OBRequest *obRequest;
@property (nonatomic, strong) OBRecommendationResponse *odbResponse;
@property (nonatomic, weak) UIView * containerView;
@property (nonatomic, strong) SFItemData *sfItem;
@property (nonatomic, weak) SFVideoCollectionViewCell *videoCell;

@end

@implementation OBVideoWidget

- (id _Nonnull )initRequest:(OBRequest * _Nonnull)obRequest
              containerView:(UIView * _Nonnull)containerView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        self.obRequest = obRequest;
        self.containerView = containerView;
    }
    return self;
}

-(void) start {
    if (self.odbResponse) {
        return;
    }
    [self loadUIInContainerView];
    [self fetchRecommendationFromOutbrain];
}

-(void) loadUIInContainerView {
    NSBundle *bundle = [NSBundle bundleForClass:[OBVideoWidget class]];
    self.videoCell = (SFVideoCollectionViewCell *)[[bundle loadNibNamed:@"SFSingleVideoWithTitleCollectionViewCell" owner:self options:nil] objectAtIndex:0];
    
    NSLog(@"rootView: %@", self.videoCell);
    [self.videoCell prepareForReuse];
    [self.containerView addSubview:self.videoCell];
    [SFUtils addConstraintsToFillParent:self.videoCell];
}

-(void) fetchRecommendationFromOutbrain {
    [Outbrain fetchRecommendationsForRequest:self.obRequest withCallback:^(OBRecommendationResponse *response) {
        if (response.error) {
            NSLog(@"Error in fetchRecommendations - %@, for widget id: %@", response.error.localizedDescription, self.obRequest.widgetId);
            return;
        }
        
        if (response.recommendations.count == 0) {
            NSLog(@"Error in fetchRecommendations - 0 recs for widget id: %@", self.obRequest.widgetId);
            return;
        }
        
        self.odbResponse = response;
        
        NSLog(@"fetchRecommendationFromOutbrain received - %lu recs, for widget id: %@", (unsigned long)response.recommendations.count, self.obRequest.widgetId);
        
        if ([SFUtils isVideoIncludedInResponse:response] && response.recommendations.count == 1) {
            NSString *videoParamsStr = [SFUtils videoParamsStringFromResponse:response];
            NSURL *videoURL = [SFUtils appendParamsToVideoUrl: response];
            self.sfItem = [[SFItemData alloc] initWithVideoUrl:videoURL
                                                     videoParamsStr:videoParamsStr
                                               singleRecommendation:response.recommendations[0]
                                                        odbResponse:response];
            
            // Report Viewability
            [[OBViewabilityService sharedInstance] reportRecsShownForRequest:self.sfItem.request];
            
            [SFCollectionViewManager configureVideoCell:self.videoCell withSFItem:self.sfItem wkUIDelegate:self clickListenerTarget:self tapGestureDelegate:self];
            
            [self.containerView setNeedsDisplay];
        }
        else {
            NSLog(@"Video is not included in response...");
        }
        
    }];
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        NSLog(@"SmartFeedManager createWebViewWith URL: %@", navigationAction.request.URL);
        if (self.delegate != nil && navigationAction.request.URL != nil) {
            [self.delegate userTappedOnVideoRec:navigationAction.request.URL];
        }
    }
    return nil;
}

#pragma mark - SFClickListener methods

- (void) recommendationClicked: (id)sender {
    NSLog(@"recommendationClicked");
    OBRecommendation *rec = self.sfItem.singleRec;
    
    if (self.delegate != nil && rec != nil) {
        [self.delegate userTappedOnRecommendation:rec];
    }
}

- (void) adChoicesClicked:(id)sender {
    NSLog(@"adChoicesClicked");
    OBRecommendation *rec = self.sfItem.singleRec;
    if (self.delegate != nil && rec != nil) {
        [self.delegate userTappedOnAdChoicesIcon:rec.disclosure.clickUrl];
    }
}

- (void) outbrainLabelClicked:(id)sender {
    NSLog(@"outbrainLabelClicked");
    if (self.delegate != nil) {
        [self.delegate userTappedOnOutbrainLabeling];
    }
}

@end
