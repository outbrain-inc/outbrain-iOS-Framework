//
//  SFItemData.m
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SFItemData.h"
#import "SFUtils.h"

@interface SFItemData()

@property (nonatomic, strong) NSArray *outbrainRecs;
@property (nonatomic, strong) OBRecommendation *singleRec;
@property (nonatomic, strong) OBSettings *odbSettings;
@property (nonatomic, assign) SFItemType itemType;
@property (nonatomic, copy) NSString *widgetTitle;
@property (nonatomic, copy) NSString *widgetId;
@property (nonatomic, strong) OBRequest *request;
@property (nonatomic, strong) OBResponseRequest *responseRequest;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) NSString *videoParamsStr;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, copy) NSString *sourceFormat;
@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, copy) NSString *requestId;
@end

@implementation SFItemData

NSInteger kVideoInitStatus = 1112;
NSInteger kVideoReadyStatus = 1113;
NSInteger kVideoFinishedStatus = 1114;

- (id)initWithSingleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type {
    self = [super init];
    if (self) {
        self.singleRec = rec;
        self.itemType = type;
        self.positions = [[NSMutableArray alloc] init];
        if (rec.position) {
            [self.positions addObject:rec.position];
        }
        [self commonInitWithResponse:odbResponse];
    }
    return self;
}

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr singleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse {
    self = [super init];
    if (self) {
        BOOL isParentResponse = odbResponse.settings.isSmartFeed;
        NSString *widgetTitle = isParentResponse ? nil : odbResponse.settings.widgetHeaderText;
        
        self.videoUrl = videoUrl;
        self.videoPlayerStatus = kVideoInitStatus;
        self.videoParamsStr = videoParamsStr;
        self.singleRec = rec;
        self.itemType = widgetTitle ? SFTypeStripVideoWithPaidRecAndTitle : SFTypeStripVideoWithPaidRecNoTitle;
        self.positions = [[NSMutableArray alloc] init];
        if (rec.position) {
            [self.positions addObject:rec.position];
        }
        [self commonInitWithResponse:odbResponse];
    }
    return self;
}


- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr reclist:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type {
    self = [super init];
    if (self) {
        self.videoUrl = videoUrl;
        self.videoPlayerStatus = kVideoInitStatus;
        self.videoParamsStr = videoParamsStr;
        self.outbrainRecs = recArray;
        self.itemType = type;
        self.positions = [[NSMutableArray alloc] init];
        for (OBRecommendation *rec in recArray) {
            if (rec.position) {
                [self.positions addObject:rec.position];
            }
        }
        [self commonInitWithResponse:odbResponse];
    }
    return self;
}

- (id)initWithList:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type {
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.itemType = type;
        self.positions = [[NSMutableArray alloc] init];
        for (OBRecommendation *rec in recArray) {
            if (rec.position) {
                [self.positions addObject:rec.position];
            }
        }
        [self commonInitWithResponse:odbResponse];
    }
    return self;
}

- (void) commonInitWithResponse:(OBRecommendationResponse *)odbResponse
{
    self.odbSettings = odbResponse.settings;
    self.request = odbResponse.request;
    self.responseRequest = odbResponse.responseRequest;
    self.widgetTitle = self.odbSettings.widgetHeaderText;
    self.widgetId = [odbResponse.responseRequest getStringValueForPayloadKey:@"widgetJsId"];
    if (self.odbSettings.smartfeedShadowColor) {
        self.shadowColor = [SFUtils colorFromHexString:self.odbSettings.smartfeedShadowColor];
    }
    self.sourceFormat = self.odbSettings.sourceFormat;
    self.requestId = [odbResponse.responseRequest getStringValueForPayloadKey:@"req_id"];
}

+(NSString *) itemTypeString:(SFItemType) type {
    if (type == SFTypeSmartfeedHeader) {
        return @"SFTypeSmartfeedHeader";
    }
    else if (type == SFTypeStripNoTitle) {
        return @"SFTypeStripNoTitle";
    }
    else if (type == SFTypeCarouselWithTitle) {
        return @"SFTypeCarouselWithTitle";
    }
    else if (type == SFTypeCarouselNoTitle) {
        return @"SFTypeCarouselNoTitle";
    }
    else if (type == SFTypeGridTwoInRowNoTitle) {
        return @"SFTypeGridTwoInRowNoTitle";
    }
    else if (type == SFTypeStripWithTitle) {
        return @"SFTypeStripWithTitle";
    }
    else if (type == SFTypeStripWithThumbnailNoTitle) {
        return @"SFTypeStripWithThumbnailNoTitle";
    }
    else if (type == SFTypeStripWithThumbnailWithTitle) {
        return @"SFTypeStripWithThumbnailWithTitle";
    }
    else if (type == SFTypeGridThreeInRowNoTitle) {
        return @"SFTypeGridThreeInRowNoTitle";
    }
    else if (type == SFTypeGridThreeInRowWithTitle) {
        return @"SFTypeGridThreeInRowWithTitle";
    }
    else if (type == SFTypeGridTwoInRowWithTitle) {
        return @"SFTypeGridTwoInRowWithTitle";
    }
    else if (type == SFTypeStripVideo) {
        return @"SFTypeStripVideo";
    }
    else if (type == SFTypeStripVideoWithPaidRecAndTitle) {
        return @"SFTypeStripVideoWithPaidRecAndTitle";
    }
    else if (type == SFTypeStripVideoWithPaidRecNoTitle) {
        return @"SFTypeStripVideoWithPaidRecNoTitle";
    }
    else if (type == SFTypeGridTwoInRowWithVideo) {
        return @"SFTypeGridTwoInRowWithVideo";
    }
    else if (type == SFTypeBadType) {
        return @"SFTypeBadType";
    }
    
    return @"";
}
@end
