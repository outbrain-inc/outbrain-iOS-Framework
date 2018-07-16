//
//  SFItemData.h
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendation.h"
#import "SmartFeedManager.h"

@interface SFItemData : NSObject

- (id)initWithSingleRecommendation:(OBRecommendation *)rec type:(SFItemType)type;;

- (id)initWithList:(NSArray *)recArray type:(SFItemType)type;

@property (nonatomic, strong, readonly) NSArray *outbrainRecs;
@property (nonatomic, strong, readonly) OBRecommendation *singleRec;
@property (nonatomic, assign, readonly) SFItemType itemType;

+(NSString *) itemTypeString:(SFItemType) type;

@end
