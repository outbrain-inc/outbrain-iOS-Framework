//
//  SmartFeedManager.h
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

@protocol SmartFeedDelegate <NSObject>

-(void) userTappedOnRecommendation:(OBRecommendation *_Nonnull)rec;

-(void) userTappedOnAdChoicesIcon:(NSURL *_Nonnull)url;

-(void) userTappedOnVideoRec:(NSURL *_Nonnull)url;

-(void) userTappedOnOutbrainLabeling;

@optional
-(void) smartFeedResponseReceived:(NSArray<OBRecommendation *> *_Nonnull)recommendations forWidgetId:(NSString *_Nonnull)widgetId;

-(BOOL) isVideoCurrentlyPlaying;

-(CGSize) carouselItemSize;

-(void) configureHorizontalItem:(SFCollectionViewCell * _Nonnull)sfCollectionViewCell withRec:(OBRecommendation * _Nonnull)rec;

@end


@interface SmartFeedManager : NSObject

typedef enum
{
    SFTypeSmartfeedHeader = 1,
    SFTypeStripNoTitle,
    SFTypeCarouselWithTitle,
    SFTypeCarouselNoTitle,
    SFTypeGridTwoInRowNoTitle,
    SFTypeGridThreeInRowNoTitle,
    SFTypeGridTwoInRowWithTitle,
    SFTypeGridThreeInRowWithTitle,
    SFTypeStripWithTitle,
    SFTypeStripWithThumbnailNoTitle,
    SFTypeStripWithThumbnailWithTitle,
    SFTypeStripVideo,
    SFTypeStripVideoWithPaidRecAndTitle,
    SFTypeStripVideoWithPaidRecNoTitle,
    SFTypeGridTwoInRowWithVideo,
    SFTypeBadType
} SFItemType;

@property (nonatomic, strong, readonly) NSString * _Nullable url;
@property (nonatomic, strong, readonly) NSString * _Nullable widgetId;
@property (nonatomic, copy) NSString * _Nullable externalID;

@property (nonatomic, assign) NSInteger outbrainSectionIndex;
@property (nonatomic, strong, readonly) NSMutableArray *smartFeedItemsArray;

@property (nonatomic, weak) id<SmartFeedDelegate> delegate;
@property (nonatomic, assign) CGFloat horizontalContainerMargin;

@property (nonatomic) BOOL isVideoEligible;

-(NSInteger) smartFeedItemsCount;

// TableView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView;


- (NSInteger)numberOfSectionsInTableView;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

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
-(NSString * _Nullable) sfItemTypeStringFor:(NSIndexPath *)indexPath;

-(SFItemType) sfItemTypeFor:(NSIndexPath *)indexPath;

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forWidgetId:(NSString *)widgetId;

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forSFItemType:(SFItemType)itemType;

- (void) setTransparentBackground: (BOOL)isTransparentBackground;

-(NSArray * _Nullable) recommendationsForIndexPath:(NSIndexPath * _Nonnull)indexPath;

-(void) pauseVideo;

@end
