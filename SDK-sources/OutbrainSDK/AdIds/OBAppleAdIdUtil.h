//
//  OBAppleAdIdUtil.h
//  OutbrainSDK
//
//  Created by Oded Regev on 10/2/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBAppleAdIdUtil : NSObject

+ (BOOL)isOptedOut;
+ (NSString *)getAdvertiserId;

@end
