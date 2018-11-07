//
//  SFUtils.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation SFUtils

+(void) addConstraintsToFillParent:(UIView *)view {
    UIView *parentView = view.superview;
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[view leadingAnchor] constraintEqualToAnchor:[parentView leadingAnchor] constant:0].active = YES;
    [[view trailingAnchor] constraintEqualToAnchor:[parentView trailingAnchor] constant:0].active = YES;
    [[view topAnchor] constraintEqualToAnchor:[parentView topAnchor] constant:0].active = YES;
    [[view bottomAnchor] constraintEqualToAnchor:[parentView bottomAnchor] constant:0].active = YES;
    
    [view setNeedsLayout];
}

+(void) addConstraintsToFillParentWithHorizontalMargin:(UIView *)view {
    UIView *parentView = view.superview;
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[view leadingAnchor] constraintEqualToAnchor:[parentView leadingAnchor] constant: 10].active = YES;
    [[view trailingAnchor] constraintEqualToAnchor:[parentView trailingAnchor] constant: -10].active = YES;
    [[view topAnchor] constraintEqualToAnchor:[parentView topAnchor] constant:0].active = YES;
    [[view bottomAnchor] constraintEqualToAnchor:[parentView bottomAnchor] constant:0].active = YES;
    
    [view setNeedsLayout];
}

+(void) addHeightConstraint:(CGFloat) height toView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *heightConst = [NSLayoutConstraint
                                  constraintWithItem:view
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:0
                                  constant:height];
    [view addConstraint:heightConst];
}

+(void) addDropShadowToView:(UIView *)view {
    [self addDropShadowToView:view shadowColor:nil];
}

+(void) addDropShadowToView:(UIView *)view shadowColor:(UIColor *)shadowColor {
    view.layer.cornerRadius = 4.0f;
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    
    view.layer.shadowColor = shadowColor != nil ? shadowColor.CGColor : [[UIColor lightGrayColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 2.0f);
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 1.0f;
    view.layer.masksToBounds = NO;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius].CGPath;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(BOOL) isRTL:(NSString *)string {
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString: string];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    return [language isEqualToString:@"he"];
}

#pragma mark - Video related methods
+(WKWebView *) createVideoWebViewInsideView:(UIView *)parentView
                                 withSFItem:(SFItemData *)sfItem
                       scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler
                                 uiDelegate:(id <WKUIDelegate>)uiDelegate
                       withHorizontalMargin:(BOOL)withHorizontalMargin
{
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    WKWebViewConfiguration *webviewConf = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:scriptMessageHandler name:@"sdkObserver"];
    webviewConf.userContentController = controller;
    webviewConf.allowsInlineMediaPlayback = YES;
    webviewConf.preferences = preferences;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:parentView.frame configuration:webviewConf];
    webView.UIDelegate = uiDelegate;
    [parentView addSubview:webView];
    webView.alpha = 0;
    if (withHorizontalMargin) {
        [self addConstraintsToFillParentWithHorizontalMargin:webView];
    }
    else {
        [self addConstraintsToFillParent:webView];
    }
    
    return webView;
}

// return whether caller should return
+(BOOL) configureGenericVideoCell:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem {
    videoCell.sfItem = sfItem;
    
    if (sfItem.videoPlayerStatus == kVideoReadyStatus) {
        [videoCell.contentView setNeedsLayout];
        return YES;
    }
    
    if (videoCell.webview) {
        [videoCell.webview removeFromSuperview];
        videoCell.webview = nil;
    }
    return NO;
}

+(void) loadRequestIn:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem {
    NSURLRequest *request = [NSURLRequest requestWithURL:sfItem.videoUrl];
    [videoCell.webview loadRequest:request];
    [videoCell.contentView setNeedsLayout];
}

@end
