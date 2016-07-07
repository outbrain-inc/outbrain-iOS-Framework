//
//  OBBridge.h
//  OutbrainSDK
//
//  Created by Oded Regev on 7/4/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBBridge : NSObject

/** @section Custom OBWebView **/

+ (BOOL) isOutbrainPaidUrl:(NSURL *)url;

+ (BOOL) shouldOpenInSafariViewController:(NSURL *)url;

// Return status - success or failure
+ (BOOL) registerOutbrainResponse:(NSDictionary *)jsonDictionary;

@end
