//
//  SFItemData.m
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFItemData.h"

@interface SFItemData()

@property (nonatomic, strong) NSArray *outbrainRecs;
@property (nonatomic, strong) OBRecommendation *singleRec;
@property (nonatomic, assign) SFItemType itemType;
@property (nonatomic, copy) NSString *widgetTitle;

@end

@implementation SFItemData


- (id)initWithSingleRecommendation:(OBRecommendation *)rec type:(SFItemType)type widgetTitle:(NSString *)widgetTitle {
    self = [super init];
    if (self) {
        self.singleRec = rec;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
    }
    return self;
}

- (id)initWithList:(NSArray *)recArray type:(SFItemType)type widgetTitle:(NSString *)widgetTitle {
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
    }
    return self;
}

+(NSString *) itemTypeString:(SFItemType) type {
    if (type == SingleItem) {
        return @"SingleItem";
    }
    else if (type == CarouselItem) {
        return @"CarouselItem";
    }
    else if (type == GridTwoInRowNoTitle) {
        return @"GridTwoInRowNoTitle";
    }
    else if (type == StripWithTitle) {
        return @"StripWithTitle";
    }
    else if (type == StripWithThumbnail) {
        return @"StripWithThumbnail";
    }
    else if (type == GridThreeInRowNoTitle) {
        return @"GridThreeInRowNoTitle";
    }
    
    return @"";
}
@end
