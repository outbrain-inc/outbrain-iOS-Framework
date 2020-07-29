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

@interface SFHorizontalViewWeeklyHighlights()

@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic, assign) CGFloat scrollOffsetX;
@property (nonatomic, assign) BOOL isAutoScrollStarted;
@property (nonatomic, strong) NSArray *sortedRecsByDate;

@end

@implementation SFHorizontalViewWeeklyHighlights

- (void)setupView {
    [super setupView];
    [self storeSortedRecsByDate];
    [self registerWeeklyHighlightsNibs];
    if (!self.isAutoScrollStarted) {
        [self startAutoScrollTimer];
    }
}

- (void)storeSortedRecsByDate {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    self.sortedRecsByDate = [self.sfItem.outbrainRecs sortedArrayUsingDescriptors:@[sortDescriptor]];
}


- (void)registerWeeklyHighlightsNibs {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *horizontalItemCellNib = nil;
    
    horizontalItemCellNib = [UINib nibWithNibName:@"SFWeeklyHighlightsItemOneCell" bundle:bundle];
    [self.collectionView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFWeeklyHighlightsItemOneCell"];
    
    horizontalItemCellNib = [UINib nibWithNibName:@"SFWeeklyHighlightsItemTwoCell" bundle:bundle];
    [self.collectionView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFWeeklyHighlightsItemTwoCell"];
}

- (void)startAutoScrollTimer {
    float timeInterval = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0.02 : 0.045;
    self.autoScrollTimer = [NSTimer
                            timerWithTimeInterval:timeInterval
                            target:self
                            selector:@selector(updateCollectionViewOffset)
                            userInfo:nil
                            repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:self.autoScrollTimer forMode: NSRunLoopCommonModes];
    self.isAutoScrollStarted = true;
}

- (void)updateCollectionViewOffset {
    float scrollOffsetXBy = 0.7;
    CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x + scrollOffsetXBy, 0);
    self.collectionView.contentOffset = newContentOffset;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (self.sortedRecsByDate.count / 3) * 2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // for continuously scroll
    // https://stackoverflow.com/questions/35938580/making-a-uicollectionview-continuously-scroll
    CGPoint offset = self.collectionView.contentOffset;
    double width = self.collectionView.contentSize.width;
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
    long cells = self.sortedRecsByDate.count / 3;
    long index = indexPath.item;
    if (index > cells - 1) {
        index -= cells;
    }
    
    NSArray *cellTypeOnePositions = @[@0,@2,@4,@5];
    
    NSString *reuseIdentifier = [cellTypeOnePositions containsObject:[NSNumber numberWithLong:index % cells]] ? @"SFWeeklyHighlightsItemOneCell" : @"SFWeeklyHighlightsItemTwoCell";
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (![cell isKindOfClass:[SFWeeklyHighlightsItemCell class]]) {
        return cell;
    }
    
    // configure cell
    SFWeeklyHighlightsItemCell *weeklyHighlightsCell = (SFWeeklyHighlightsItemCell *) cell;
    long firstPositionOfRec = (index % cells) * 3;
    [self configureWeeklyHighlightsCell:weeklyHighlightsCell withFirstPositionInSortedRecsArray:firstPositionOfRec];
    
    return weeklyHighlightsCell;
}

- (void) configureWeeklyHighlightsCell: (SFWeeklyHighlightsItemCell *)cell withFirstPositionInSortedRecsArray:(long)firstPositionOfRec {
    
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
    [self roundedCorners:4 forView:cell.dateView onlyBottom:true];
    
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
        [self roundedCorners:4 forView:recView onlyBottom:false];
        
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

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // override method to avoid clicks on cells
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.autoScrollTimer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startAutoScrollTimer];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    long screenWidth = UIScreen.mainScreen.bounds.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(screenWidth * 0.5, self.frame.size.height);
    } else {
        return CGSizeMake(screenWidth * 0.7, self.frame.size.height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}

- (void)roundedCorners:(float) cornerRadius forView:(UIView *)view onlyBottom:(bool) onlyBottom  {
    int options = UIRectCornerBottomLeft | UIRectCornerBottomRight;
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
