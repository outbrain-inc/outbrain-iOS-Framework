//
//  OBIPadInStreamRecommendationsView.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBIPadInStreamCell.h"
#import "OBWidgetViewProtocol.h"

@class OBRecommendation;
@class OBRecommendationResponse;

@protocol OBIPadInStreamRecommendationsViewDelegate<NSObject>
- (void)itemClickedAtIndex:(NSIndexPath *)indexPath;
@end

@protocol OBIPadInStreamRecommendationsViewDataSource<NSObject>

@required
- (NSString *)titleForIndex:(NSIndexPath *)index;
- (NSString *)sourceForIndex:(NSIndexPath *)index;
- (NSString *)categoryForIndex:(NSIndexPath *)index;
- (NSString *)imageUrlForIndex:(NSIndexPath *)index;
- (NSInteger)numberOfItems;
- (CGSize)sizeForIndex:(NSIndexPath *)index;
@end

@interface OBIPadInStreamRecommendationsView : UIView {
    __weak id<OBIPadInStreamRecommendationsViewDataSource> dataSource;
    __weak id<OBIPadInStreamRecommendationsViewDelegate> delegate;
}

@property (nonatomic, weak) id<OBIPadInStreamRecommendationsViewDataSource> dataSource;
@property (nonatomic, weak) id<OBIPadInStreamRecommendationsViewDelegate> delegate;

/** @name Callbacks **/

/**
 *  Discussion:
 *      Handler for when the widget detects that the user tapped on a recommendation.
 *
 *  @note:  You can optionally use the `widgetDelegate` instead
 **/
@property (nonatomic, copy) OBWRecommendationTappedHandler recommendationTapHandler;

/**
 *  Discussion:
 *      Delegate style handler for those who don't like using the block style handlers.
 *
 **/
@property (nonatomic, weak) IBOutlet id <OBWidgetViewDelegate> widgetDelegate;

/**
 *  Discussion:
 *      This is the actual response given from the sdk.
 **/
@property (nonatomic, strong) OBRecommendationResponse * recommendationResponse;

/**
 *  Discussion:
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;
- (void)reloadData;
@end
