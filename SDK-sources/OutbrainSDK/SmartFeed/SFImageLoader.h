//
//  SFImageLoader.h
//  OutbrainSDK
//
//  Created by oded regev on 07/05/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFImageLoader : NSObject

+ (instancetype)sharedInstance;

-(void) loadImage:(NSURL *)imageUrl into:(UIImageView *)imageView;

-(void) loadImageToCacheIfNeeded:(NSURL *)imageUrl;

@end
