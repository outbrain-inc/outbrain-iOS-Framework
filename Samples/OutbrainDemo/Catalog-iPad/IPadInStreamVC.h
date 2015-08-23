//
//  IPadInStreamVC.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBIPadInStreamRecommendationsView.h"

@interface IPadInStreamVC : UIViewController <OBIPadInStreamRecommendationsViewDataSource, OBIPadInStreamRecommendationsViewDelegate> {
    OBRecommendationResponse *recommendationResponse;
    IBOutlet OBIPadInStreamRecommendationsView *recommendationsView;
    
    NSMutableArray *sampleDataModel;
}

@property (nonatomic, strong) OBRecommendationResponse *recommendationResponse;
@property (nonatomic, strong) IBOutlet OBIPadInStreamRecommendationsView *recommendationsView;
@end
