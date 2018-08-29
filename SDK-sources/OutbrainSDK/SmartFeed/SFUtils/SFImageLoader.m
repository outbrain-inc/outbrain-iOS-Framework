//
//  SFImageLoader.m
//  OutbrainSDK
//
//  Created by oded regev on 07/05/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFImageLoader.h"

@interface SFImageLoader()
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSOperationQueue *imageQueue;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *adChoicesDefaultImage;
@end

@implementation SFImageLoader

+ (instancetype)sharedInstance
{
    static SFImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFImageLoader alloc] init];
        sharedInstance.imageCache = [[NSCache alloc] init];
        sharedInstance.imageQueue = [[NSOperationQueue alloc] init];
        sharedInstance.imageQueue.maxConcurrentOperationCount = 4;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        sharedInstance.placeholderImage = [UIImage imageNamed:@"placeholder-image" inBundle:bundle compatibleWithTraitCollection:nil];
        sharedInstance.adChoicesDefaultImage = [UIImage imageNamed:@"adchoices-icon" inBundle:bundle compatibleWithTraitCollection:nil];
    });
    return sharedInstance;
}

-(void) loadImage:(NSURL *)imageUrl into:(UIImageView *)imageView {
    imageView.image = self.placeholderImage;
    imageView.tag = [imageUrl.absoluteString hash];
    
    NSData *imageData = [self.imageCache objectForKey:imageUrl.absoluteString];
    if (imageData != nil) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             imageView.image = [UIImage imageWithData:imageData];
         }];
        return;
    }
    
    [self.imageQueue addOperationWithBlock:^{
        NSData *data = [[NSData alloc] initWithContentsOfURL: imageUrl];
        if ( data == nil )
            return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (imageView.tag != [imageUrl.absoluteString hash]) {
                // NSLog(@"SFImageLoader: imageView has changed - no need to load with image..");
                return;
            }
            imageView.image = [UIImage imageWithData:data];
        }];
        [self.imageCache setObject:data forKey:imageUrl.absoluteString];
    }];
}

-(void) loadImage:(NSString *)imageUrlStr intoButton:(UIButton *)button {
    [button setImage:self.adChoicesDefaultImage forState:UIControlStateNormal];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlStr];
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
        if ( data == nil )
            return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (button.imageView.tag != [imageUrl.absoluteString hash]) {
                // NSLog(@"SFImageLoader: imageView has changed - no need to load with image..");
                return;
            }
            [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
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
