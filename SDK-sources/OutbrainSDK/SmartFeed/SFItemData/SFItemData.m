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
@property (nonatomic, copy) NSString *widgetId;

@end

@implementation SFItemData


- (id)initWithSingleRecommendation:(OBRecommendation *)rec type:(SFItemType)type widgetTitle:(NSString *)widgetTitle widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.singleRec = rec;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
        self.widgetId = widgetId;
    }
    return self;
}

- (id)initWithList:(NSArray *)recArray type:(SFItemType)type widgetTitle:(NSString *)widgetTitle widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
        self.widgetId = widgetId;
    }
    return self;
}

+(NSString *) itemTypeString:(SFItemType) type {
    if (type == SFTypeSingleItem) {
        return @"SFTypeSingleItem";
    }
    else if (type == SFTypeCarouselItem) {
        return @"SFTypeCarouselItem";
    }
    else if (type == SFTypeGridTwoInRowNoTitle) {
        return @"SFTypeGridTwoInRowNoTitle";
    }
    else if (type == SFTypeStripWithTitle) {
        return @"SFTypeStripWithTitle";
    }
    else if (type == SFTypeStripWithThumbnail) {
        return @"SFTypeStripWithThumbnail";
    }
    else if (type == SFTypeGridThreeInRowNoTitle) {
        return @"SFTypeGridThreeInRowNoTitle";
    }
    
    return @"";
}
@end
