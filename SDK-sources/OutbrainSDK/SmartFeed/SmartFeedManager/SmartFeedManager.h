//
//  SmartFeedManager.h
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OBRecommendation.h"
#import "SFCollectionViewCell.h"

@protocol SmartFeedDelegate <NSObject>

/**
 * @brief called when the user has tapped on a recommendation in the Smartfeed
 *
 * @param rec - the OBRecommendation the user has tapped on
 **/
-(void) userTappedOnRecommendation:(OBRecommendation *_Nonnull)rec;

/**
 * @brief called when the user has tapped on the "ad choice" icon.
 *
 * @param url - the url to open in an external browser to support "Ad choices" guidelines
 **/
-(void) userTappedOnAdChoicesIcon:(NSURL *_Nonnull)url;

/**
 * @brief called when the user has tapped on the video player in the Smartfeed
 *
 * @param url - the video "click url" to open in an external browser
 **/
-(void) userTappedOnVideoRec:(NSURL *_Nonnull)url;

/**
 * @brief called when the user has tapped on the Outbrain logo. Please make sure to follow the guidelines.
 *
 **/
-(void) userTappedOnOutbrainLabeling;

@optional
-(void) smartFeedResponseReceived:(NSArray<OBRecommendation *> *_Nonnull)recommendations forWidgetId:(NSString *_Nonnull)widgetId;

/**
 * @brief app developer implement this method to let the SmartFeedManager check if there is a video currently playing
 * in the app (in an article for example). If the app returns "true" the SDK will not play a video in the Smartfeed.
 *
 * @return true if video is currently playing in the app
 **/
-(BOOL) isVideoCurrentlyPlaying;

/**
 * @brief belongs to "custom UI" - app developer can implement this method to customize the UI of Smartfeed carousel horizontal item.
 *
 * @return the CGSize of Smartfeed horizontal carousel item.
 **/
-(CGSize) carouselItemSize;

/**
 * @brief belongs to "custom UI" - app developer can implement this method to manually configure an "horizontal cell" before it
 * is displayed to the user.
 *
 * @param sfCollectionViewCell - the SFCollectionViewCell to configure
 * @param rec - the content of the recommendation to be displayed in the cell
 *
 **/
-(void) configureHorizontalItem:(SFCollectionViewCell * _Nonnull)sfCollectionViewCell withRec:(OBRecommendation * _Nonnull)rec;

/**
 * @brief this method is relevant only in case Smartfeed is displayed in the middle of the feed (not at the end).
 * SmartFeedManager will notify the app developer when the Smartfeed is ready with recs to be displayed so the
 * data source can reload the feed to integrate Outbrain recs within it.
 *
 **/
-(void) smartfeedIsReadyWithRecs;

@end


@interface SmartFeedManager : NSObject

typedef enum
{
    SFTypeSmartfeedHeader = 1,
    SFTypeStripNoTitle,
    SFTypeCarouselWithTitle,
    SFTypeBrandedCarouselWithTitle,
    SFTypeWeeklyHighlightsWithTitle,
    SFTypeCarouselNoTitle,
    SFTypeGridTwoInRowNoTitle,
    SFTypeGridThreeInRowNoTitle,
    SFTypeGridTwoInRowWithTitle,
    SFTypeGridThreeInRowWithTitle,
    SFTypeStripWithTitle,
    SFTypeStripWithThumbnailNoTitle,
    SFTypeStripWithThumbnailWithTitle,
    SFTypeStripAppInstall,
    SFTypeStripVideo,
    SFTypeStripVideoWithPaidRecAndTitle,
    SFTypeStripVideoWithPaidRecNoTitle,
    SFTypeGridTwoInRowWithVideo,
    SFTypeGridTwoInRowWithTitleWithVideo,
    SFTypeBadType
} SFItemType;

@property (nonatomic, assign) NSInteger outbrainWidgetIndex;
@property (nonatomic, assign) BOOL isInMiddleOfScreen;
@property (nonatomic, assign) BOOL darkMode;
@property (nonatomic, assign) BOOL disableCellShadows;
@property (nonatomic, assign) BOOL useDefaultCollectionViewDelegate;
@property (nonatomic, assign, readonly) BOOL hasMore;
@property (nonatomic, strong, readonly) NSString * _Nullable url;
@property (nonatomic, strong, readonly) NSString * _Nullable widgetId;
@property (nonatomic, copy) NSString * _Nullable externalID;

@property (nonatomic, assign) NSInteger outbrainSectionIndex;
@property (nonatomic, strong, readonly) NSMutableArray * _Nonnull smartFeedItemsArray;

@property (nonatomic, weak) id<SmartFeedDelegate> _Nullable delegate;
@property (nonatomic, assign) CGFloat horizontalContainerMargin;

@property (nonatomic) BOOL isVideoEligible;
@property (nonatomic) BOOL displaySourceOnOrganicRec;
@property (nonatomic) BOOL isSkySolutionActive;

-(NSInteger) smartFeedItemsCount;

// TableView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView;


- (NSInteger)numberOfSectionsInTableView;

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void)tableView:(UITableView * _Nonnull)tableView willDisplayCell:(UITableViewCell * _Nonnull)cell forRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

// CollectionView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
             collectionView:(UICollectionView * _Nonnull)collectionView;

- (NSInteger)numberOfSectionsInCollectionView;

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView
                  layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (UICollectionViewCell *_Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void)collectionView:(UICollectionView * _Nonnull)collectionView
       willDisplayCell:(UICollectionViewCell * _Nonnull)cell
    forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

// Common Methods
-(NSString * _Nullable) sfItemTypeStringFor:(NSIndexPath * _Nonnull)indexPath;

-(SFItemType) sfItemTypeFor:(NSIndexPath * _Nonnull)indexPath;

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forWidgetId:(NSString * _Nonnull)widgetId;

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forSFItemType:(SFItemType)itemType;

- (void) setTransparentBackground: (BOOL)isTransparentBackground;

-(NSArray * _Nullable) recommendationsForIndexPath:(NSIndexPath * _Nonnull)indexPath;

-(void) pauseVideo;

- (void) fetchMoreRecommendations;

@end
