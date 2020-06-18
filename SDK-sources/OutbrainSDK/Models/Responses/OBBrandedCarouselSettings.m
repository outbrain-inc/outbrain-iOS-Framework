//
//  OBBrandedCarouselSettings.m
//  OutbrainSDK
//
//  Created by oded regev on 25/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "OBBrandedCarouselSettings.h"

@interface OBBrandedCarouselSettings()

@property (nonatomic, copy) NSString * carouselTitle;
@property (nonatomic, copy) NSString * carouselSponsor;
@property (nonatomic, copy) NSString * carouselType;
@property (nonatomic, strong) NSURL * carouselClickUrl;
@property (nonatomic, strong) OBImageInfo *image;

@end



@implementation OBBrandedCarouselSettings

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        self.carouselTitle = [payload valueForKey:@"content"];
        self.carouselSponsor = [payload valueForKey:@"carouselSponsor"];
        self.carouselType = [payload valueForKey:@"carousel_type"];
        self.image = [OBImageInfo contentWithPayload:[payload valueForKey:@"thumbnail"]];
        self.carouselClickUrl = [[NSURL alloc] initWithString:[payload valueForKey:@"url"]];
    }
    return self;
}


@end
