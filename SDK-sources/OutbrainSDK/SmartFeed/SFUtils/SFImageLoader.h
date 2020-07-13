//
//  SFImageLoader.h
//  OutbrainSDK
//
//  Created by oded regev on 07/05/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OBImageInfo.h"

@interface SFImageLoader : NSObject

+ (instancetype)sharedInstance;

-(void) loadImageUrl:(NSURL *)imageUrl into:(UIImageView *)imageView;

//
// @param abTestDuration - (-1) if fade = false in abTest, (milliseconds value) if abTest apply or default value of 750m
//
-(void) loadRecImage:(OBImageInfo *)imageInfo into:(UIImageView *)imageView withFadeDuration:(NSInteger)abTestDuration;
    
-(void) loadImage:(NSString *)imageUrlStr intoButton:(UIButton *)button;

-(void) loadImageToCacheIfNeeded:(NSURL *)imageUrl;

@end
