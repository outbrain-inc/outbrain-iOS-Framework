//
//  OBNetworkManager.h
//  OutbrainSDK
//
//  Created by oded regev on 10/9/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBNetworkManager : NSObject

typedef void (^OBNetworkCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error);

+ (id)sharedManager;

-(void) sendGet:(NSURL *)url completionHandler:(OBNetworkCompletionBlock)completionHandler;

-(void) sendPost:(NSURL *)url postData:(id)postDataString completionHandler:(OBNetworkCompletionBlock)completionHandler;

@end
