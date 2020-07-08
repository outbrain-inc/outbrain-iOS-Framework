//
//  SFImageLoader.m
//  OutbrainSDK
//
//  Created by oded regev on 07/05/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFImageLoader.h"
#import "SFUtils.h"
@import WebKit;

@interface SFImageLoader()
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSMutableDictionary *imageLoadedOnceDict;
@property (nonatomic, strong) NSOperationQueue *imageQueue;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *adChoicesDefaultImage;
@end

@implementation SFImageLoader

NSInteger const AB_TEST_NO_FADE = -1;
NSInteger const GIF_WEBVIEW_TAG = 223344;


+ (instancetype)sharedInstance
{
    static SFImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFImageLoader alloc] init];
        sharedInstance.imageCache = [[NSCache alloc] init];
        sharedInstance.imageQueue = [[NSOperationQueue alloc] init];
        sharedInstance.imageLoadedOnceDict = [[NSMutableDictionary alloc] init];
        sharedInstance.imageQueue.maxConcurrentOperationCount = 4;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        sharedInstance.placeholderImage = [UIImage imageNamed:@"placeholder-image" inBundle:bundle compatibleWithTraitCollection:nil];
        sharedInstance.adChoicesDefaultImage = [UIImage imageNamed:@"adchoices-icon" inBundle:bundle compatibleWithTraitCollection:nil];
    });
    return sharedInstance;
}

//
// @param abTestDuration - (-1) if fade = false in abTest, (milliseconds value) if abTest apply
//
-(void) loadRecImage:(OBImageInfo *)imageInfo into:(UIImageView *)imageView withFadeDuration:(NSInteger)abTestDuration {
    UIView *wkWebView = [imageView viewWithTag:GIF_WEBVIEW_TAG];
    if (wkWebView) {
        [wkWebView removeFromSuperview];
    }
    
    if (imageInfo.isGif) {
        [self loadGifImageUrl:imageInfo.url into:imageView];
    }
    else {
        [self loadImageUrl:imageInfo.url into:imageView withFadeDuration:abTestDuration];
    }
}

-(void) loadImageUrl:(NSURL *)imageUrl into:(UIImageView *)imageView {
    [self loadImageUrl:imageUrl into:imageView withFadeDuration:1];
}

//
// @param abTestDuration - (-1) if fade = false in abTest, (milliseconds value) if abTest apply
//
-(void) loadImageUrl:(NSURL *)imageUrl into:(UIImageView *)imageView withFadeDuration:(NSInteger)abTestDuration {
    CGFloat adjustedDuration = abTestDuration / 1000.0;
    if (adjustedDuration > 1.5 || adjustedDuration < 0) {
        adjustedDuration = 0.75; // back to default
    }

    imageView.image = self.placeholderImage;
    imageView.tag = [imageUrl.absoluteString hash];
    
    NSData *imageData = [self.imageCache objectForKey:imageUrl.absoluteString];
    if (imageData != nil) {
        // NSLog(@"SFImageLoader: loading image from cache");
        UIImage *cachedImage = [UIImage imageWithData:imageData];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.imageLoadedOnceDict[imageUrl.absoluteString] != nil) {
                imageView.image = cachedImage;
            }
            else {
                self.imageLoadedOnceDict[imageUrl.absoluteString] = @1;
                if (abTestDuration == AB_TEST_NO_FADE) {
                    imageView.image = cachedImage;
                }
                else {
                    [self loadImage:cachedImage withFadeInDuration:adjustedDuration toImageView:imageView];
                }
            }
        }];
        return;
    }
    
    [self.imageQueue addOperationWithBlock:^{
        NSData *data = [[NSData alloc] initWithContentsOfURL: imageUrl];
        if ( data == nil ) {
            return;
        }
        UIImage *downloadedImage = [UIImage imageWithData:data];
        if (downloadedImage == nil) {
            NSLog(@"SFImageLoader: downloadedImage is nil - check image url: %@", imageUrl.absoluteString);
            return;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (imageView.tag != [imageUrl.absoluteString hash]) {
                // NSLog(@"SFImageLoader: imageView has changed - no need to load with image..");
                return;
            }
            self.imageLoadedOnceDict[imageUrl.absoluteString] = @1;
            if (abTestDuration == AB_TEST_NO_FADE) {
                imageView.image = downloadedImage;
            }
            else {
                [self loadImage:downloadedImage withFadeInDuration:adjustedDuration toImageView:imageView];
            }
        }];
        [self.imageCache setObject:data forKey:imageUrl.absoluteString];
    }];
}

-(void) loadGifImageUrl:(NSURL *)imageUrl into:(UIImageView *)imageView {
    WKWebView *webView = [[WKWebView alloc] initWithFrame:imageView.frame];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"gif-image-template" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"IMAGE" withString:imageUrl.absoluteString];
    
    webView.tag = GIF_WEBVIEW_TAG;
    [webView loadHTMLString:htmlString baseURL:nil];
    [imageView addSubview:webView];
    [SFUtils addConstraintsToFillParent:webView];
}

-(void) loadImage:(UIImage *)image withFadeInDuration:(CGFloat)duration toImageView:(UIImageView *)imageView {
    imageView.alpha = 0.f;
    imageView.image = image;
    
    //fade in
    [UIView animateWithDuration:duration delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
        imageView.alpha = 1.0f;
        
    } completion: nil];
}

-(void) loadImage:(NSString *)imageUrlStr intoButton:(UIButton *)button {
    [button setImage:self.adChoicesDefaultImage forState:UIControlStateNormal];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlStr];
    if (imageUrl == nil) {
        return;
    }
    button.imageView.tag = [imageUrl.absoluteString hash];

    NSData *imageData = [self.imageCache objectForKey:imageUrl.absoluteString];
    if (imageData != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [button setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        }];
        return;
    }
    
    [self.imageQueue addOperationWithBlock:^{
        NSData *data = [[NSData alloc] initWithContentsOfURL: imageUrl];
        if ( data == nil ) {
            return;
        }
        UIImage *downloadedImage = [UIImage imageWithData:data];
        if (downloadedImage == nil) {
            NSLog(@"SFImageLoader: downloadedImage is nil - check image url: %@", imageUrl.absoluteString);
            return;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (button.imageView.tag != [imageUrl.absoluteString hash]) {
                // NSLog(@"SFImageLoader: imageView has changed - no need to load with image..");
                return;
            }
            [button setImage:downloadedImage forState:UIControlStateNormal];
        }];
        [self.imageCache setObject:data forKey:imageUrl.absoluteString];
    }];
}

-(void) loadImageToCacheIfNeeded:(NSURL *)imageUrl {
    NSData *imageData = [self.imageCache objectForKey:imageUrl.absoluteString];
    if (imageData != nil) {
        return;
    }
    
    [self.imageQueue addOperationWithBlock:^{
        NSData *data = [[NSData alloc] initWithContentsOfURL: imageUrl];
        if ( data == nil )
            return;
        [self.imageCache setObject:data forKey:imageUrl.absoluteString];
    }];
}

@end
