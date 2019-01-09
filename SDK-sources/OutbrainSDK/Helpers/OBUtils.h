//
//  OBUtils.h
//  OutbrainSDK
//
//  Created by oded regev on 11/20/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBUtils : NSObject

+(NSString *) deviceModel;

+(NSString *) decodeHTMLEnocdedString:(NSString *)htmlEncodedString;

@end
