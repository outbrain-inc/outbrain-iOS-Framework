//
//  OBWidget.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRequest.h"

@interface OBRequest()
@property (nonatomic, copy) NSString * mobileId;
@property (nonatomic, copy) NSString * source;
@end

@implementation OBRequest

+ (instancetype)requestWithURL:(NSString *)link widgetID:(NSString *)widgetID
{
    return [self requestWithURL:link widgetID:widgetID widgetIndex:0];
}

+ (instancetype)requestWithURL:(NSString *)link widgetID:(NSString *)widgetID widgetIndex:(NSInteger)widgetIndex
{
    NSAssert((widgetID != nil) && (widgetID.length > 0), @"WidgetID must not be empty.");
    
    OBRequest * request = [[[self class] alloc] init];
    request.url = link;
    request.widgetId = widgetID;
    request.widgetIndex = widgetIndex;
    
    return request;
}


#pragma mark - Comparison

- (BOOL)isEqualToOBRequest:(OBRequest *)request
{
    if(!request) return NO; // Request is nil
    BOOL linksAreEqual = [self.url isEqualToString:request.url];
    BOOL widgetIDsAreEqueal = [self.widgetId isEqualToString:request.widgetId];
    return linksAreEqual && widgetIDsAreEqueal;
}

- (BOOL)isEqual:(id)object
{
    if(self == object) return YES;
    if(![object isKindOfClass:[OBRequest class]]) return NO;
    return [self isEqualToOBRequest:(OBRequest *)object];
}

- (NSUInteger)hash
{
    return [self.url hash] ^ [self.widgetId hash];
}

@end
