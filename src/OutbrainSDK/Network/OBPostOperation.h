//
//  OBPostOperation.h
//  OutbrainSDK
//
//  Created by Oded Regev on 6/12/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBPostOperation : NSOperation

@property (nonatomic, strong) NSDictionary *postData;

+ (instancetype)operationWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url;

@end
