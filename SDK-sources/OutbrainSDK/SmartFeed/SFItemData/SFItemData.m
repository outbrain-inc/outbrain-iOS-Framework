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


- (id)initWithSingleRecommendation:(OBRecommendation *)rec type:(SFItemType)type widgetTitle:(NSString *)widgetTitle widgetId:(NSString *)widgetId shadowColorStr:(NSString *)shadowColorStr {
    self = [super init];
    if (self) {
        self.singleRec = rec;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
        self.widgetId = widgetId;
        if (shadowColorStr) {
            self.shadowColor = [SFUtils colorFromHexString:shadowColorStr];
        }
    }
    return self;
}

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams singleRecommendation:(OBRecommendation *)rec widgetTitle:(NSString *)widgetTitle widgetId:(NSString *)widgetId shadowColorStr:(NSString *)shadowColorStr {
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
        self.itemType = widgetTitle ? SFTypeStripVideoWithPaidRecAndTitle : SFTypeStripVideoWithPaidRecNoTitle;
        self.widgetTitle = widgetTitle;
        self.widgetId = widgetId;
        if (shadowColorStr) {
            self.shadowColor = [SFUtils colorFromHexString:shadowColorStr];
        }
    }
    return self;
}

- (id)initWithList:(NSArray *)recArray type:(SFItemType)type widgetTitle:(NSString *)widgetTitle widgetId:(NSString *)widgetId shadowColorStr:(NSString *)shadowColorStr {
    
    self = [super init];
    if (self) {
        self.outbrainRecs = recArray;
        self.itemType = type;
        self.widgetTitle = widgetTitle;
        self.widgetId = widgetId;
        if (shadowColorStr) {
            self.shadowColor = [SFUtils colorFromHexString:shadowColorStr];
        }
    }
    return self;
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
    
    return @"";
}
@end
