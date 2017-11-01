//
//  OBOBIPadInterstitialClassicView.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/7/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//
//
//  OBInterstitialClassicView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/28/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBIPadInterstitialClassicView.h"
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBLabelExtensions.h"
#import "OBLabelWithPadding.h"
#import "OBIPadInterstitialClassicViewCell.h"

//HEADER DEFINES
#define OBOrange [UIColor colorWithRed:0.914 green:0.506 blue:0.129 alpha:1.000]
#define OBDarkOrange [UIColor colorWithRed:185/255.0 green:96/255.0 blue:0 alpha:1.000]
#define TRIANGLE_SIDE 15
#define LABEL_LEFT_PADDING 20
#define LABEL_TOP_PADDING 5
#define LEFT_RIGHT_CELL_MARGIN 10

//VIEW DEFINES
#define NAVIGATION_BAR_PADDING 44.0f
#define STATUS_BAR_PADDING 20.0f
#define LEFT_RIGHT_PADDING 20.0f
#define TOP_HEADER_PADDING 10.0f
#define CELL_LABELS_SIDE_PADDING 10.0f
#define CELL_HORIZONTAL_SPACING 5.0f
#define CELL_VERTICAL_SPACING 5.0f

@interface OBIPadInterstitialHeader : UIView
@property (nonatomic, strong) UIView *orangeContainer;
@property (nonatomic, assign) float ameliaHeaderHeight;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *brandingImageButton;
@property (nonatomic, assign) id<OBIPadInterstitialHeaderDelegate> delegate;
@end

@interface OBIPadInterstitialClassicView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView * internalCollectionView;
@property (nonatomic, weak) UIView * loadMoreFooterView;
@property (nonatomic, strong) NSMutableArray * recommendations;

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, strong) OBIPadInterstitialHeader *header;
@end


@implementation OBIPadInterstitialClassicView

NSInteger const kActivityIndicatorTag = 222;


#pragma mark - Initialize

- (void)commonInit
{
    self.header = [[OBIPadInterstitialHeader alloc] initWithFrame:CGRectMake(LEFT_RIGHT_PADDING, NAVIGATION_BAR_PADDING + STATUS_BAR_PADDING + TOP_HEADER_PADDING, self.frame.size.width - 2*LEFT_RIGHT_PADDING, 40)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGRect frame = self.bounds;
    frame = CGRectOffset(frame, LEFT_RIGHT_PADDING + TRIANGLE_SIDE, CGRectGetMaxY(self.header.frame) - 20.0f);
    frame.size.width -= 2 * LEFT_RIGHT_PADDING + TRIANGLE_SIDE;
    frame.size.height -= CGRectGetMaxY(self.header.frame) + 40.0f;

    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    cv.backgroundColor = [UIColor clearColor];
    cv.delegate = self;
    cv.dataSource = self;
//    cv.backgroundColor = [UIColorFromRGB(0xF4F4F4) colorWithAlphaComponent:0.94f];
    cv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [cv registerClass:[OBIPadInterstitialClassicViewCell class] forCellWithReuseIdentifier:@"RecommendationCell"];
    [cv registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LoadMoreFooterID"];
    [self addSubview:cv];
    _internalCollectionView = cv;
    [self addSubview:self.header];
    // Set default loading view
    
    // Stup a default loading view
    UIView * v = [[UIView alloc] initWithFrame:self.bounds];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    v.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.000];
    
    UILabel * loadingLabel = [UILabel new];
    loadingLabel.textColor = [UIColor orangeColor];
    loadingLabel.font = [UIFont boldSystemFontOfSize:20.f];
    loadingLabel.text = @"Loading Recommendations...";
    [loadingLabel sizeToFit];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.center = v.center;
    [v addSubview:loadingLabel];
    
    UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indy.center = CGPointMake(loadingLabel.center.x, CGRectGetMaxY(loadingLabel.frame) + 50.f);
    indy.hidesWhenStopped = YES;
    indy.tag = kActivityIndicatorTag;
    [indy startAnimating];
    [v addSubview:indy];
    
    self.loadingView = v;
    
    self.backgroundColor = [UIColor whiteColor];
    self.recommendations = [NSMutableArray array];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)orientationChanged:(UIDevice *)device {
    [self.internalCollectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }

- (void)resetData
{
    [self.recommendations removeAllObjects];
    [self.internalCollectionView reloadData];
}

- (void)fetchNextSetOfRecommendations
{
    self.loading = YES;
    typeof(self) __weak __self = self;
    [Outbrain fetchRecommendationsForRequest:self.request withCallback:^(OBRecommendationResponse *response) {
        
        if(response && response.recommendations.count > 0)
        {
            [__self.recommendations addObject:response.recommendations];
            [__self.internalCollectionView reloadData];
            __self.request.widgetIndex += 1;
        }
        __self.loading = NO;
    }];
}


#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.recommendations.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.recommendations[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"RecommendationCell";
    OBIPadInterstitialClassicViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    OBRecommendation * rec = self.recommendations[indexPath.section][indexPath.row];
    [cell setRecommendation:rec];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OBRecommendation * recommendation = self.recommendations[indexPath.section][indexPath.row];
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
    if(self.widgetDelegate)
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
}

static float maxCellHeight = 0;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    OBRecommendation * rec = self.recommendations[indexPath.section][indexPath.row];
    CGSize cellSize = [OBIPadInterstitialClassicViewCell sizeForRec:rec collectionViewWidth:self.internalCollectionView.frame.size.width];
    maxCellHeight = MAX(maxCellHeight, cellSize.height);
    return CGSizeMake(cellSize.width, maxCellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(CELL_VERTICAL_SPACING, CELL_HORIZONTAL_SPACING, CELL_VERTICAL_SPACING, CELL_HORIZONTAL_SPACING);
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [self.internalCollectionView.collectionViewLayout invalidateLayout];
    [super setFrame:frame];
}

- (void)setRequest:(OBRequest *)request
{
    if([_request isEqual:request]) return;
    _request = request;
    [self resetData];
    [self fetchNextSetOfRecommendations];
}

- (void)setLoading:(BOOL)loading
{
    if(_loading == loading) return;
    _loading = loading;
    
    UIButton * b = (UIButton *)[self.loadMoreFooterView viewWithTag:101];
    UIActivityIndicatorView * indy = (UIActivityIndicatorView *)[self.loadingView viewWithTag:kActivityIndicatorTag];
    
    loading ? [indy startAnimating] : [indy stopAnimating];
    [UIView animateWithDuration:.25f animations:^{
        b.alpha = _loading ? 0 : 1.f;
    }];
    
    if(_loading && self.recommendations.count == 0)
    {
        [self addSubview:self.loadingView];
    }
    
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.loadingView.alpha = _loading?1.f:0.f;
                     } completion:^(BOOL finished) {
                         if(!_loading)
                         {
                             [self.loadingView removeFromSuperview];
                         }
                     }];
}

- (void)brandingDidClick {
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}

@end


// Wrapper to put the interstitial inside a viewControlelr
@implementation OBIPadInterstitialClassicVC

- (OBIPadInterstitialClassicView *)classicView
{
    if (!_classicView)
    {
        OBIPadInterstitialClassicView * v = [[OBIPadInterstitialClassicView alloc] initWithFrame:self.view.bounds];
        _classicView = v;
        [self.view addSubview:v];
    }
    return _classicView;
}

@end

@implementation OBIPadInterstitialHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.orangeContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,20)];
        self.orangeContainer.backgroundColor = OBOrange;
        [self addSubview:self.orangeContainer];
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,20)];
        self.headerLabel.text = @"We also recommend";
        self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        [self.headerLabel sizeToFit];
        self.headerLabel.textColor = [UIColor whiteColor];
        [self.orangeContainer addSubview:self.headerLabel];
        
        self.brandingImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.brandingImageButton addTarget:self action:@selector(brandingDidClick) forControlEvents:UIControlEventTouchUpInside];
        self.brandingImageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.brandingImageButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
        CGRect r = CGRectMake(0, 0, 71, 18);
        r.origin.y = self.ameliaHeaderHeight;
        r.origin.x = (self.frame.size.width - r.size.width - 5.f - LEFT_RIGHT_CELL_MARGIN);
        self.brandingImageButton.frame = r;
        [self addSubview:self.brandingImageButton];
        
        self.orangeContainer.frame = CGRectMake(0,0,LABEL_LEFT_PADDING*2 + self.headerLabel.frame.size.width, self.headerLabel.frame.size.height + LABEL_TOP_PADDING*2);
        self.headerLabel.frame = CGRectMake(LABEL_LEFT_PADDING, LABEL_TOP_PADDING, self.headerLabel.frame.size.width,self.headerLabel.frame.size.height);
        self.brandingImageButton.center = CGPointMake(self.brandingImageButton.center.x, CGRectGetMidY(self.orangeContainer.frame));
    }
    return self;
}

- (void)brandingDidClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(brandingDidClick)]) {
        [self.delegate brandingDidClick];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    float bottomLabel = CGRectGetMaxY(self.orangeContainer.frame);
    [path moveToPoint:CGPointMake(0, bottomLabel)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel + 2*TRIANGLE_SIDE/3)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel)];
    [path closePath];
    [OBDarkOrange set];
    [path fill];
}

@end

