//
//  SFUtils.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFUtils.h"
#import "OBAppleAdIdUtil.h"
#import "OutbrainManager.h"

#import <QuartzCore/QuartzCore.h>

NSString * const OB_VIDEO_PAUSE_NOTIFICATION     =   @"OB_VIDEO_PAUSE_NOTIFICATION";
NSInteger const AB_TEST_FONT_STYLE_BOLD = 1;

@implementation SFUtils

static SFUtils *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[SFUtils alloc] init];
    }
}

+(SFUtils *) sharedInstance {
    return sharedSingleton;
}

-(UIColor *) primaryBackgroundColor {
    if (self.darkMode) {
        return UIColor.blackColor;
    }
    else {
        return UIColor.whiteColor;
    }
}

-(UIColor *) titleColor:(BOOL) isPaid {
    if (self.darkMode) {
        return UIColor.whiteColor;
    }
    else {
        return UIColorFromRGB(0x282828);
    }
}

-(UIColor *) subtitleColor:(NSString *)abTestSourceFontColor {
    if (self.darkMode) {
        return UIColorFromRGB(0xA4A3A8);
    }
    else {
        return abTestSourceFontColor ?
            [SFUtils colorFromHexString: abTestSourceFontColor] :
            UIColorFromRGB(0x707070);
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


// Skip RTL (Sky optimization)
static BOOL skipRTL;
+ (BOOL) skipRTL {
    return skipRTL;
}
+ (void) setSkipRTL:(BOOL)val {
    skipRTL = val;
}
// End

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
    dispatch_async(dispatch_get_main_queue(), ^{
        view.layer.cornerRadius = 4.0f;
        view.layer.borderWidth = 1.0f;
        view.layer.borderColor = [UIColor clearColor].CGColor;

        view.layer.shadowColor = shadowColor != nil ? shadowColor.CGColor : [[UIColor lightGrayColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(0, 2.0f);
        view.layer.shadowRadius = 2.0f;
        view.layer.shadowOpacity = 1.0f;
        view.layer.masksToBounds = NO;
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius].CGPath;
    });
}

+ (void) removePaidLabelFromImageView:(UIImageView *)recImageView {
    UILabel *existingPaidLabel = (UILabel *)[recImageView viewWithTag: SPONSORED_LABEL_TAG];
    if (existingPaidLabel) {
        [existingPaidLabel removeFromSuperview];
    }
}

+ (void) configurePaidLabelToImageViewIfneeded:(UIImageView *)recImageView withSettings:(OBSettings *)settings {
    
    if (!settings.paidLabelText || [settings.paidLabelText isEqualToString:@""]) {
        // no settings for paidLabelText --> we will return
        return;
    }
    
    UILabel *paidLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    paidLabel.text = settings.paidLabelText;
    paidLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
    paidLabel.textColor = settings.paidLabelTextColor ? [self colorFromHexString:settings.paidLabelTextColor] : UIColor.whiteColor;
    paidLabel.textAlignment = NSTextAlignmentCenter;
    paidLabel.backgroundColor = [self colorFromHexString:settings.paidLabelBackgroundColor ? settings.paidLabelBackgroundColor : @"#4d4d4d"];
    paidLabel.tag = SPONSORED_LABEL_TAG;
    BOOL isRTL = [SFUtils isRTL:settings.paidLabelText];
    [recImageView addSubview:paidLabel];
    
    // Calculate label size
    NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:settings.paidLabelText
                                        attributes:@{NSFontAttributeName: paidLabel.font}];
    CGRect rect = [attributedText boundingRectWithSize:recImageView.frame.size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize expectedLabelSize = rect.size;
    
    [self addConstraint:NSLayoutAttributeHeight     constant:expectedLabelSize.height + 6.0 toView:paidLabel];
    [self addConstraint:NSLayoutAttributeWidth      constant:expectedLabelSize.width + 20.0 toView:paidLabel];
    [self addConstraint:(isRTL ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading)    constant:0 baseView:recImageView        toView:paidLabel];
    [self addConstraint:NSLayoutAttributeBottom 	constant:0 baseView:recImageView        toView:paidLabel];
}

+(BOOL) isRTL:(NSString *)string {
    NSArray *rtlLanguages = @[@"he", @"ar", @"fa"];
    if (skipRTL) {
        return NO; // Sky optimization
    }

    if (string == nil || string.length == 0) {
        return NO;
    }

    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString: string];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    BOOL testBegining = [rtlLanguages containsObject:language];
    
    NSInteger middleIndex = string.length/2;
    middleIndex = [string characterAtIndex:middleIndex] == ' ' ? middleIndex + 1 : middleIndex;
    language = [tagger tagAtIndex:middleIndex scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    BOOL testMiddle = [rtlLanguages containsObject:language];
    
    return testBegining || testMiddle;
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
    webView.scrollView.scrollEnabled = NO;
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

+(void) loadVideoURLIn:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem {
    NSURLRequest *request = [NSURLRequest requestWithURL:sfItem.videoUrl];
    [videoCell.webview loadRequest:request];
    [videoCell.contentView setNeedsLayout];
}

+(BOOL) isVideoIncludedInResponse:(OBRecommendationResponse *)response {
    BOOL videoIsIncludedInRequest = [[response.responseRequest getStringValueForPayloadKey:@"vid"] integerValue] == 1;
    return videoIsIncludedInRequest;
}

+(NSString *) videoParamsStringFromResponse:(OBRecommendationResponse *)response {
    NSMutableDictionary *videoParams = [[NSMutableDictionary alloc] init];
    if (response.originalOBPayload[@"settings"]) {
        videoParams[@"settings"] = response.originalOBPayload[@"settings"];
    }
    if (response.originalOBPayload[@"request"]) {
        videoParams[@"request"] = response.originalOBPayload[@"request"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"initWithVideoUrl Got an error: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(NSURL *) appendParamsToVideoUrl:(OBRecommendationResponse *)response url:(NSString *)url {
    NSString *videoUrlStr = response.settings.videoUrl.absoluteString;
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:videoUrlStr];
    NSMutableArray *odbQueryItems = [[NSMutableArray alloc] initWithArray:components.queryItems];
    NSString *appNameStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *apiUserId = [OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value: @"ios"]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"inApp" value: @"true"]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appName" value: appNameStr]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appBundle" value: bundleIdentifier]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"sdkVersion" value: OB_SDK_VERSION]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"deviceIfa" value: apiUserId]];
    if (url != nil) {
        NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSString *formattedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:set];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"articleUrl" value: formattedUrl]];
    }
    
    if ([OutbrainManager sharedInstance].testMode) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"testMode" value: @"true"]];
    }
    
    components.queryItems = odbQueryItems;
    return components.URL;
}

+(NSString *) getSourceTextForRec:(OBRecommendation *)rec withSettings:(OBSettings *)obSettings {
    if (rec.isPaidLink) {
        if (obSettings.paidSourceFormat) {
            if ([obSettings.paidSourceFormat containsString:@"$SOURCE"] && rec.source) {
                return [obSettings.paidSourceFormat stringByReplacingOccurrencesOfString:@"$SOURCE" withString:rec.source];
            }
            else {
                return obSettings.paidSourceFormat;
            }
        }
    }
    else { // Organic rec
        if (obSettings.organicSourceFormat) {
            if ([obSettings.organicSourceFormat containsString:@"$SOURCE"] && rec.source) {
                return [obSettings.organicSourceFormat stringByReplacingOccurrencesOfString:@"$SOURCE" withString:rec.source];
            }
            else {
                return obSettings.organicSourceFormat;
            }
        }
    }
    
    return rec.source;
}

+(void) setFontSizeForTitleLabel:(UILabel *)titleLabel andSourceLabel:(UILabel *)sourceLabel withAbTestSettings:(OBSettings *)settings {
    BOOL isNotSingleColumn = [settings.recMode isEqualToString:@"sdk_sfd_2_columns"] || [settings.recMode isEqualToString:@"sdk_sfd_3_columns"];
    CGFloat defaultSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 19.0 : 18.0;
    if (isNotSingleColumn) {
        defaultSize = 16.0; // according to Zeplin
    }
    CGFloat titleFontSize = defaultSize;
    // AB test abTitleFontSize
    if (settings.abTitleFontSize > 12 && settings.abTitleFontSize < 20) {
        titleFontSize = settings.abTitleFontSize;
    }
    
    // AB test abTitleFontStyle
    BOOL isBold = settings.abTitleFontStyle == AB_TEST_FONT_STYLE_BOLD || settings.abTitleFontStyle == -1;
    if (isBold) {
        titleLabel.font = [UIFont systemFontOfSize:titleFontSize weight:UIFontWeightSemibold];
    }
    else {
        UIFontDescriptor *fontD = [titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits: !UIFontDescriptorTraitBold];
        titleLabel.font = [UIFont fontWithDescriptor:fontD size: titleFontSize];
    }
    

    // AB test abSourceFontSize
    if (settings.abSourceFontSize >= 10 && settings.abSourceFontSize < 16) {
        sourceLabel.font = [sourceLabel.font fontWithSize:settings.abSourceFontSize];
    }
    else {
        CGFloat defaultSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15.0 : 14.0;
        sourceLabel.font = [sourceLabel.font fontWithSize: defaultSize]; 
    }
}


+(UILabel *) getRecCtaLabelWithText:(NSString *)ctaText {
    UILabel * ctaLabelView = [[UILabel alloc] init];
    
    NSDictionary *attribs = @{
        NSForegroundColorAttributeName: UIColorFromRGB(0x5295e3),
        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]
    };
    NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString: ctaText
                                                   attributes:attribs];
    ctaLabelView.attributedText = attributedText;
    ctaLabelView.textAlignment = NSTextAlignmentCenter;
    
    ctaLabelView.layer.borderWidth = 1;
    ctaLabelView.layer.borderColor = UIColorFromRGB(0x5295e3).CGColor;
    ctaLabelView.layer.cornerRadius = 3;
    
    return ctaLabelView;
}
@end
