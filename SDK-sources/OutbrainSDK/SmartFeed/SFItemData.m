//
//  SFItemData.m
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFItemData.h"

@implementation SFItemData

- (id)init
{
    return [self initWithSingleRec:nil orList:nil];
}

- (id)initWithSingleRecommendation:(OBRecommendation *)rec
{
    return [self initWithSingleRec:rec orList:nil];
}

- (id)initWithList:(NSArray *)recArray
{
    return [self initWithSingleRec:nil orList:recArray];
}


- (id)initWithSingleRec:(OBRecommendation *)rec orList:(NSArray *)recArray
{
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.singleRec = rec;
    }
    return self;
}

-(SFItemType) itemType {
    if (self.outbrainRecs && self.outbrainRecs.count > 1) {
        return HorizontalItem;
    }
    
    return SingleItem;
}

@end
