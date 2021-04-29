//
//  OBUtils.h
//  OutbrainSDK
//
//  Created by oded regev on 11/20/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRequest.h"

@interface OBUtils : NSObject

+(NSString *) deviceModel;

+(BOOL) isDeviceSimulator;

+(NSString *) decodeHTMLEnocdedString:(NSString *)htmlEncodedString;

+(NSString *) getRequestUrl:(OBRequest *)request;

@end
