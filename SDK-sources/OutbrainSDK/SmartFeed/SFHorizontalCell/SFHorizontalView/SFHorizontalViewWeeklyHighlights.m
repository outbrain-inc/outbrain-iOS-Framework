//
//  SFHorizontalViewWeeklyHighlights.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 7/26/20.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFHorizontalViewWeeklyHighlights.h"
#import "SFWeeklyHighlightsItemCell.h"
#import "SFImageLoader.h"
#import "SFUtils.h"
#import "UIView+Visible.h"

@interface SFHorizontalViewWeeklyHighlights()

@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic, strong) NSTimer *viewabilityTimer;
@property (nonatomic, assign) CGFloat scrollOffsetX;
@property (nonatomic, assign) BOOL isForegroundBackgroundObserversAdded;
@property (nonatomic, assign) BOOL isAutoScrollTimerRunning;
@property (nonatomic, assign) BOOL isViewabilityTrackTimerRunning;
@property (nonatomic, strong) NSArray *sortedRecsByDate;

@end

@implementation SFHorizontalViewWeeklyHighlights

- (void)setupView {
    [super setupView];
    [self storeSortedRecsByDate];
    [self registerWeeklyHighlightsNibs];
    [self startViewabilityTrackTimerIfNeeded];
    [self addForegroundBackgroundObserversIfNeeded];
}

- (void)storeSortedRecsByDate {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    self.sortedRecsByDate = [self.sfItem.outbrainRecs sortedArrayUsingDescriptors:@[sortDescriptor]];
}

#pragma mark - Auto scroll methods

- (void)startAutoScrollTimerIfNeeded {
    if (self.isAutoScrollTimerRunning) { // timer already running
        return;
    }
    self.isAutoScrollTimerRunning = YES;
    
    CGFloat timeInterval = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0.02 : 0.045;
    self.autoScrollTimer = [NSTimer
                            timerWithTimeInterval:timeInterval
                            target:self
                            selector:@selector(updateCollectionViewOffset)
                            userInfo:nil
                            repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:self.autoScrollTimer forMode: NSRunLoopCommonModes];
}

- (void)stopAutoScrollTimerIfNeeded {
    if (self.isAutoScrollTimerRunning) { // timer already stoped
        [self.autoScrollTimer invalidate];
        self.isAutoScrollTimerRunning = NO;
    }
}

- (void)updateCollectionViewOffset {
    // scroll to the new position
    float scrollOffsetXBy = 0.7;
    CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x + scrollOffsetXBy, 0);
    self.collectionView.contentOffset = newContentOffset;
}


#pragma mark - Lifecycle methods

- (void)addForegroundBackgroundObserversIfNeeded {
    if (!self.isForegroundBackgroundObserversAdded) {
        // app swiched to foreground
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(appSwitchedToForeground:)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
        // app switched to background
        [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(appSwitchedToBackground:)
        name:UIApplicationWillResignActiveNotification
        object:nil];
        
        self.isForegroundBackgroundObserversAdded = YES;
    }
}

- (void)appSwitchedToBackground:(NSNotification *)note {
    [self stopAutoScrollTimerIfNeeded];
    [self stopViewabilityTrackTimerIfNeeded];
}

- (void)appSwitchedToForeground:(NSNotification *)note {
    [self startViewabilityTrackTimerIfNeeded];
}

#pragma mark - Viewability methods

- (void)startViewabilityTrackTimerIfNeeded {
    if (self.isViewabilityTrackTimerRunning) { // timer already running
        return;
    }
    self.viewabilityTimer = [NSTimer
                            timerWithTimeInterval:0.3
                            target:self
                            selector:@selector(checkViewability)
                            userInfo:nil
                            repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:self.viewabilityTimer forMode: NSRunLoopCommonModes];
    self.isViewabilityTrackTimerRunning = YES;
}

- (void)stopViewabilityTrackTimerIfNeeded {
    if (self.isViewabilityTrackTimerRunning) { // timer is running
        [self.viewabilityTimer invalidate];
        self.isViewabilityTrackTimerRunning = NO;
    }
}

- (void)checkViewability {
    if (self.percentVisible > 0) { // view is in the viewport
        [self startAutoScrollTimerIfNeeded];
    } else {
        [self stopAutoScrollTimerIfNeeded];
    }
}

#pragma mark - Collection View methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (self.sortedRecsByDate.count / 3) * 2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // for continuously scroll
    // https://stackoverflow.com/questions/35938580/making-a-uicollectionview-continuously-scroll
    CGPoint offset = self.collectionView.contentOffset;
    CGFloat width = self.collectionView.contentSize.width;
    if (offset.x < width/4) {
        offset.x += width/2;
        [self.collectionView setContentOffset:offset];
    } else if (offset.x > width/4 * 3) {
        offset.x -= width/2;
        [self.collectionView setContentOffset:offset];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // for continuously scroll
    long numberOfCells = self.sortedRecsByDate.count / 3;
    long index = indexPath.item;
    if (index > numberOfCells - 1) {
        index -= numberOfCells;
    }
    
    NSArray *cellTypeOnePositions = @[@0,@2,@4,@5];
    
    NSString *reuseIdentifier = [cellTypeOnePositions containsObject:[NSNumber numberWithLong:index % numberOfCells]] ? @"SFWeeklyHighlightsItemOneCell" : @"SFWeeklyHighlightsItemTwoCell";
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (![cell isKindOfClass:[SFWeeklyHighlightsItemCell class]]) {
        return cell;
    }
    
    // configure cell
    SFWeeklyHighlightsItemCell *weeklyHighlightsCell = (SFWeeklyHighlightsItemCell *) cell;
    long firstPositionOfRec = (index % numberOfCells) * 3;
    [self configureWeeklyHighlightsCell:weeklyHighlightsCell withFirstPositionInSortedRecsArray:firstPositionOfRec];
    
    return weeklyHighlightsCell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // override method to avoid clicks on cells
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopViewabilityTrackTimerIfNeeded];
    [self stopAutoScrollTimerIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startViewabilityTrackTimerIfNeeded];
    [self startAutoScrollTimerIfNeeded];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    long screenWidth = UIScreen.mainScreen.bounds.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // ipad
        return CGSizeMake(screenWidth * 0.5, self.frame.size.height);
    } else {
        return CGSizeMake(screenWidth * 0.7, self.frame.size.height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}

- (void)registerWeeklyHighlightsNibs {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *horizontalItemCellNib = nil;
    
    horizontalItemCellNib = [UINib nibWithNibName:@"SFWeeklyHighlightsItemOneCell" bundle:bundle];
    [self.collectionView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFWeeklyHighlightsItemOneCell"];
    
    horizontalItemCellNib = [UINib nibWithNibName:@"SFWeeklyHighlightsItemTwoCell" bundle:bundle];
    [self.collectionView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFWeeklyHighlightsItemTwoCell"];
}

- (void) configureWeeklyHighlightsCell: (SFWeeklyHighlightsItemCell *)cell withFirstPositionInSortedRecsArray:(long)firstPositionOfRec {
    // make sure that the number of recommendations is a multiple of 3
    if (firstPositionOfRec + 2 >= self.sortedRecsByDate.count) {
        return;
    }
    
    NSArray<OBRecommendation *> *recs = @[
        self.sortedRecsByDate[firstPositionOfRec],
        self.sortedRecsByDate[firstPositionOfRec + 1],
        self.sortedRecsByDate[firstPositionOfRec + 2]
    ];
    
    // date view
    [cell.dateView setBackgroundColor: [SFUtils colorFromHexString: @"#252738"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM EEE"];
    [cell.dateLabel setText:[dateFormatter stringFromDate:recs.firstObject.publishDate]];
    [cell.dateLabel setTextColor:[UIColor whiteColor]];
    [self roundedCorners:4 forView:cell.dateView onlyBottom:YES];
    
    NSArray<SFWeeklyHighlightsSingleRecView *> *recViews = @[
        cell.recOneView,
        cell.recTwoView,
        cell.recThreeView
    ];
    
    for (int i = 0; i < 3; i++) {
        SFWeeklyHighlightsSingleRecView *recView = recViews[i];
        OBRecommendation *rec = recs[i];
        
        // set rec title and image
        [recView.recTitleLabel setText:rec.content];
        [[SFImageLoader sharedInstance] loadRecImage:rec.image into:recView.recImageView withFadeDuration:-1];
        
        // rounded corners for rec view
        [self roundedCorners:4 forView:recView onlyBottom:NO];
        
        // click on rec view
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnRecommendation:)];
        recView.tag = firstPositionOfRec + i; // index of rec in sortedRecsByDate array
        [recView addGestureRecognizer:tapGesture];
    }
}

- (void) handleClickOnRecommendation: (UITapGestureRecognizer *)tapGesture {
    long recIndex = tapGesture.view.tag;
    self.onRecommendationClick(self.sortedRecsByDate[recIndex]);
}

- (void)roundedCorners:(CGFloat) cornerRadius forView:(UIView *)view onlyBottom:(BOOL) onlyBottom  {
    NSInteger options = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    if (!onlyBottom) {
        options = options | UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: options cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    view.layer.mask = maskLayer;
}

@end
