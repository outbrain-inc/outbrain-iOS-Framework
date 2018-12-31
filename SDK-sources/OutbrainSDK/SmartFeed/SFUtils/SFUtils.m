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
    
    [[view leadingAnchor] constraintEqualToAnchor:[parentView leadingAnchor] constant: 7].active = YES;
    [[view trailingAnchor] constraintEqualToAnchor:[parentView trailingAnchor] constant: -7].active = YES;
    [[view topAnchor] constraintEqualToAnchor:[parentView topAnchor] constant:0].active = YES;
    [[view bottomAnchor] constraintEqualToAnchor:[parentView bottomAnchor] constant:0].active = YES;
    
    [view setNeedsLayout];
}

+(void) addConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant toView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                  constraintWithItem:view
                                  attribute:attribute
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:0
                                  constant:constant];
    [view addConstraint:constraint];
}

+(void) addConstraint:(NSLayoutAttribute)attribute constant:(CGFloat) constant baseView:(UIView *)baseView toView:(UIView *)toView{
    baseView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:baseView
                                      attribute: attribute
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:toView
                                      attribute:attribute
                                      multiplier:1
                                      constant:constant];
    [baseView addConstraint:constraint];
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

+ (void) configurePaidLabelToImageViewIfneeded:(UIImageView *)recImageView withSettings:(OBSettings *)settings {
    UILabel *existingPaidLabel = (UILabel *)[recImageView viewWithTag: SPONSORED_LABEL_TAG];
    if (existingPaidLabel) {
        if (settings.paidLabelText) {
            // if we received a settings for paidLabelText and the cell.recImageView already has a label on it yet -
            // we should return since the label is already there.
            return;
        }
        else {
            // if we there is NO settings for paidLabelText and the cell.recImageView has a label on it yet - we will call:
            [existingPaidLabel removeFromSuperview];
            return;
        }
    }
    
    UILabel *paidLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    paidLabel.text = settings.paidLabelText;
    paidLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
    paidLabel.textColor = settings.paidLabelTextColor ? [self colorFromHexString:settings.paidLabelTextColor] : UIColor.whiteColor;
    paidLabel.textAlignment = NSTextAlignmentCenter;
    paidLabel.backgroundColor = [self colorFromHexString:settings.paidLabelBackgroundColor ? settings.paidLabelBackgroundColor : @"#666666"];
    paidLabel.tag = SPONSORED_LABEL_TAG;
    BOOL isRTL = [SFUtils isRTL:settings.paidLabelText];
    [recImageView addSubview:paidLabel];
    
    CGSize expectedLabelSize = [settings.paidLabelText sizeWithFont:paidLabel.font constrainedToSize:recImageView.frame.size lineBreakMode:paidLabel.lineBreakMode];
    
    [self addConstraint:NSLayoutAttributeHeight constant:expectedLabelSize.height + 6.0 toView:paidLabel];
    [self addConstraint:NSLayoutAttributeWidth constant:expectedLabelSize.width + 20.0 toView:paidLabel];
    [self addConstraint:(isRTL ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing) constant:0 baseView:recImageView toView:paidLabel];
    [self addConstraint:NSLayoutAttributeBottom constant:10 baseView:recImageView toView:paidLabel];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(BOOL) isRTL:(NSString *)string {
    if (string == nil || string.length == 0) {
        return NO;
    }
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

+(NSString *) getRecSourceText:(NSString *)recSource withSourceFormat:(NSString *)sourceFormat {
    if (sourceFormat && [sourceFormat containsString:@"$SOURCE"]) {
        return [sourceFormat stringByReplacingOccurrencesOfString:@"$SOURCE" withString:recSource];
    } else {
        return recSource;
    }
}

@end
