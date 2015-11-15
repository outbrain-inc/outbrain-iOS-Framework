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
    return [self privateRequestWithURL:link widgetID:widgetID widgetIndex:widgetIndex];
}

+ (instancetype)privateRequestWithURL:(NSString *)link widgetID:(NSString *)widgetID widgetIndex:(NSInteger)widgetIndex
{
    NSAssert((widgetID != nil) && (widgetID.length > 0), @"WidgetID must not be empty.");
    NSAssert((link != nil) && (link.length > 0), @"URL must not be empty.");
    
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

#if 0
// Currently commenting out these methods, there is a chance we'll add them to the SDK in the future.
- (void)setMobileSubGroup:(NSString *)mobileSubGroup {
    self.source = mobileSubGroup;
}

- (NSString *)mobileSubGroup {
    return self.source;
}

- (void)setAdditionalData:(NSString *)additionalData {
    self.mobileId = additionalData;
}

- (NSString *)additionalData {
    return self.mobileId;
}
#endif // end of comment out


#pragma mark - Getters & Setters

- (NSString *)description {
    return [NSString stringWithFormat: @"WidgetId:%@;WidgetIndex:%ld;AdditionalData:%@;MobileSubGroup:%@;", self.widgetId, (long)self.widgetIndex, self.mobileId, self.source];
}

@end
