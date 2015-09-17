//
//  OBGAOperation.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/19/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBGAOperation : NSOperation <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSMutableData       *_responseData;
    NSString            *_methodName;
    NSString            *_paramString;
    NSString            *_appKey;
    NSString            *_appVersion;
}

@property (atomic, getter=isExecuting) BOOL executing;
@property (atomic, getter=isFinished) BOOL finished;
@property (nonatomic, strong, readonly) NSURLConnection *connection;

- (instancetype)initWithMethodName:(NSString *)methodName withParams:(NSString *)params appKey:(NSString *)appKey appVersion:(NSString *)appVersion;

@end
