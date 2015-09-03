//
//  IPadInStreamVC.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "IPadInStreamVC.h"

@interface OBSampleDataModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *imageUrl;

@end
@implementation OBSampleDataModel
@end

@implementation IPadInStreamVC
@synthesize recommendationResponse;
@synthesize recommendationsView;

- (void)assignSampleDataModel {
    sampleDataModel = [[NSMutableArray alloc] init];

    OBSampleDataModel *dma = [OBSampleDataModel new];
    dma.title = @"Sample Data Model A";
    dma.author = @"Outbrain";
    dma.category = @"Sports";
    dma.imageUrl = @"http://graphics8.nytimes.com/images/2013/08/13/science/video-pod-st-sports/video-pod-st-sports-articleLarge.jpg";
    
    OBSampleDataModel *dmb = [OBSampleDataModel new];
    dmb.title = @"Sample Data Model B";
    dmb.author = @"Outbrain";
    dmb.category = @"Business";
    dmb.imageUrl = @"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQ6dPAcP2e5EZlUkIxXZDbKv6pGYRRs5-hCglRioSO99LjeOeVq";
    
    OBSampleDataModel *dmc = [OBSampleDataModel new];
    dmc.title = @"Sample Data Model C";
    dmc.author = @"Outbrain";
    dmc.category = @"Music";
    dmc.imageUrl = @"http://www.real.com/resources/wp-content/uploads/2013/05/streaming-MP41.jpg";

    [sampleDataModel addObject:dma];
    [sampleDataModel addObject:dmb];
    [sampleDataModel addObject:dmc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"In-Stream";

    recommendationsView.delegate = self;
    recommendationsView.dataSource = self;
    OBRequest * request = [OBRequest requestWithURL:kOBRecommendationLink widgetID:@"SDK_2"];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        // If the response was successful then pass the response to the widget
        
        if(response.error)
        {
            // We want to hide our recommendations view since the request failed to get recommendations
            self.recommendationsView.hidden = YES;
            NSLog(@"Got error from recommendations request %@", response.error);

        }
        else
        {
            // We have a valid list of recommendations.
            self.recommendationResponse = response;
            [self assignSampleDataModel];
            self.recommendationsView.recommendationResponse = response;
            [UIView animateWithDuration:.25f animations:^{
                // Fade it in
                self.recommendationsView.alpha = 1;
            }];
        }
        [self.recommendationsView reloadData];
    }];
}

- (NSString *)titleForIndex:(NSIndexPath *)index {
    if ([self shouldShowRecommendationForIndex:index]) {
        OBRecommendation *rec = [recommendationResponse.recommendations objectAtIndex:[self recommendationForIndex:index.row]];
        return rec.content;
    }
    OBSampleDataModel *dataModel = [sampleDataModel objectAtIndex:[self organicRecForIndex:index.row]];
    return dataModel.title;
}

- (NSString *)sourceForIndex:(NSIndexPath *)index {
    if ([self shouldShowRecommendationForIndex:index]) {
        OBRecommendation *rec = [recommendationResponse.recommendations objectAtIndex:[self recommendationForIndex:index.row]];
        return rec.source;
    }
    OBSampleDataModel *dataModel = [sampleDataModel objectAtIndex:[self organicRecForIndex:index.row]];
    return dataModel.author;
}

- (NSString *)categoryForIndex:(NSIndexPath *)index {
    if ([self shouldShowRecommendationForIndex:index]) {
        return @"FROM THE WEB";
    }
    OBSampleDataModel *dataModel = [sampleDataModel objectAtIndex:[self organicRecForIndex:index.row]];
    return [dataModel.category uppercaseString];
}

- (NSString *)imageUrlForIndex:(NSIndexPath *)index {
    if ([self shouldShowRecommendationForIndex:index]) {
        OBRecommendation *rec = [recommendationResponse.recommendations objectAtIndex:[self recommendationForIndex:index.row]];
        return [rec.image.url absoluteString];
    }
    OBSampleDataModel *dataModel = [sampleDataModel objectAtIndex:[self organicRecForIndex:index.row]];
    return dataModel.imageUrl;
}

- (NSInteger)numberOfItems {
    return [self.recommendationResponse.recommendations count] + [sampleDataModel count];
}

- (CGSize)sizeForIndex:(NSIndexPath *)indexPath {
    if (![self shouldShowRecommendationForIndex:indexPath]) {
        return CGSizeMake(500, 270);
    }
    return CGSizeMake(250, 270);
}

- (void)itemClickedAtIndex:(NSIndexPath *)indexPath {
    
    id itemClicked = [self getItemAtIndex:indexPath];
    NSURL * url;
    
    // Now we have a url that we can show in a webview, or if it's a piece of our native content
    // Then we can inspect [url hash] to get the mobile_id
    
    NSString * title;
    NSString * message;
    
    if ([itemClicked isKindOfClass:[OBRecommendation class]]) {
        title = @"Recommendation Tapped!";
        url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:(OBRecommendation *)itemClicked];
        message = [NSString stringWithFormat:@"User tapped recommendation.  Need to present content for this url %@", [url absoluteString]];
    }
    else {
        title = @"Organic Content Tapped!";
        message = [NSString stringWithFormat:@"User tapped Organic content.  Need to present content for this Item: %@", ((OBSampleDataModel *)itemClicked).title];

    }
    // This recommendations was tapped.
    // Here is where we register the click with outbrain for this piece of content
    
    UIAlertView * a = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [a show];
}

- (id)getItemAtIndex:(NSIndexPath *)indexPath {
    int organicIndex = 0;
    int paidIndex = 0;
    for (int i = 0; i <= indexPath.row; i++) {
        if (i == indexPath.row) {
            if ([self shouldShowRecommendationForIndex:[NSIndexPath indexPathForRow:i inSection:0]]) {
                return recommendationResponse.recommendations[paidIndex];
            }
            else {
                return sampleDataModel[organicIndex];
            }
        }
        else {
            if ([self shouldShowRecommendationForIndex:[NSIndexPath indexPathForRow:i inSection:0]]) {
                paidIndex++;
            }
            else {
                organicIndex++;
            }
        }
    }
    return nil;
}

- (BOOL)shouldShowRecommendationForIndex:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        return !(row == 1 || row == 2 || row == 5);
    }
    else {
        return !(row == 2 || row == 4 || row == 6);
    }
}

- (NSInteger)organicRecForIndex:(NSInteger)index {
    int realIndex = -1;
    int i = 0;
    while (i <= index) {
        if (![self shouldShowRecommendationForIndex:[NSIndexPath indexPathForRow:i inSection:0]]) {
            realIndex++;
        }
        i++;
    }
    return realIndex;
}

- (NSInteger)recommendationForIndex:(NSInteger)index {
    int realIndex = -1;
    int i = 0;
    while (i <= index) {
        if ([self shouldShowRecommendationForIndex:[NSIndexPath indexPathForRow:i inSection:0]]) {
            realIndex++;
        }
        i++;
    }
    return realIndex;
}

@end
