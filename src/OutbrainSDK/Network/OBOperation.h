//
//  OBOperation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class is used as a base operation class
 *  for any outbrain operations
 **/

@interface OBOperation : NSOperation <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSData *_responseData;
}

+ (instancetype)operationWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

+ (NSString *) webviewUserAgent;

@property (nonatomic, strong, readonly) NSURLConnection *connection;


@end
