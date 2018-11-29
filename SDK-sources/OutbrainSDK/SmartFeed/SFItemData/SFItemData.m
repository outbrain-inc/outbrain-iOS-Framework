//
//  SFItemData.m
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFItemData.h"
#import "SFUtils.h"

@interface SFItemData()

@property (nonatomic, strong) NSArray *outbrainRecs;
@property (nonatomic, strong) OBRecommendation *singleRec;
@property (nonatomic, strong) OBSettings *odbSettings;
@property (nonatomic, assign) SFItemType itemType;
@property (nonatomic, copy) NSString *widgetTitle;
@property (nonatomic, copy) NSString *widgetId;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) NSString *videoParamsStr;
@property (nonatomic, strong) UIColor *shadowColor;
@end

@implementation SFItemData

NSInteger kVideoInitStatus = 1112;
NSInteger kVideoReadyStatus = 1113;
NSInteger kVideoFinishedStatus = 1114;


- (id)initWithSingleRecommendation:(OBRecommendation *)rec odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.singleRec = rec;
        self.itemType = type;
        [self commonInitWithWidgetId:widgetId odbSettings:odbSettings];
    }
    return self;
}

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams singleRecommendation:(OBRecommendation *)rec odbSettings:(OBSettings *)odbSettings widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.videoUrl = videoUrl;
        self.videoPlayerStatus = kVideoInitStatus;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoParams
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"initWithVideoUrl Got an error: %@", error);
        } else {
            self.videoParamsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        self.singleRec = rec;
        self.itemType = odbSettings.widgetHeaderText ? SFTypeStripVideoWithPaidRecAndTitle : SFTypeStripVideoWithPaidRecNoTitle;
        [self commonInitWithWidgetId:widgetId odbSettings:odbSettings];
    }
    return self;
}

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams reclist:(NSArray *)recArray odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.videoUrl = videoUrl;
        self.videoPlayerStatus = kVideoInitStatus;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoParams
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"initWithVideoUrl Got an error: %@", error);
        } else {
            self.videoParamsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        self.outbrainRecs = recArray;
        self.itemType = type;
        [self commonInitWithWidgetId:widgetId odbSettings:odbSettings];
    }
    return self;
}

- (id)initWithList:(NSArray *)recArray odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId {
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.itemType = type;
        [self commonInitWithWidgetId:widgetId odbSettings:odbSettings];
    }
    return self;
}

- (void) commonInitWithWidgetId:(NSString *)widgetId
                   odbSettings:(OBSettings *)odbSettings
{
    self.widgetTitle = odbSettings.widgetHeaderText;
    self.widgetId = widgetId;
    if (odbSettings.smartfeedShadowColor) {
        self.shadowColor = [SFUtils colorFromHexString:odbSettings.smartfeedShadowColor];
    }
}

+(NSString *) itemTypeString:(SFItemType) type {
    if (type == SFTypeStripNoTitle) {
        return @"SFTypeSingleItem";
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
        return @"SFTypeStripWithThumbnail";
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
    
    return @"";
}
@end
