//
//  SFItemData.h
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendation.h"

@interface SFItemData : NSObject

- (id)initWithSingleRecommendation:(OBRecommendation *)rec;

- (id)initWithList:(NSArray *)recArray;

typedef enum
{
    SingleItem = 1,
    CarouselItem,
    GridTwoInRowNoTitle,
} SFItemType;

@property (nonatomic, strong) NSArray *outbrainRecs;
@property (nonatomic, strong) OBRecommendation *singleRec;

-(SFItemType) itemType;

@end
