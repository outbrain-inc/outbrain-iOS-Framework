//
//  OBInterstitialClassicView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/28/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBInterstitialClassicView.h"
#import "OBDemoDataHelper.h"

#import <OutbrainSDK/OutbrainSDK.h>

@interface OBInterstitialClassicView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView * internalCollectionView;
@property (nonatomic, weak) UIView * loadMoreFooterView;
@property (nonatomic, strong) NSMutableArray * recommendations;

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@end


@implementation OBInterstitialClassicView

#pragma mark - Initialize

- (void)commonInit
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(145,150);
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 0, 10);
    flowLayout.minimumInteritemSpacing = 10.f;
    flowLayout.minimumLineSpacing = 10.f;
    
    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    cv.delegate = self;
    cv.dataSource = self;
    cv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"RecommendationCell"];
    [cv registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LoadMoreFooterID"];
    [self addSubview:cv];
    _internalCollectionView = cv;
    
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
    loadingLabel.center = CGPointMake(v.bounds.size.width/2.f, v.bounds.size.height/2.f);
    [v addSubview:loadingLabel];
    
    UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indy.center = CGPointMake(loadingLabel.center.x, CGRectGetMaxY(loadingLabel.frame) + 50.f);
    indy.hidesWhenStopped = YES;
    [indy startAnimating];
    [v addSubview:indy];
    
    self.loadingView = v;
    
    self.backgroundColor = [UIColor whiteColor];
    self.recommendations = [NSMutableArray array];
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Fetching

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

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
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImageView * iv = (UIImageView *)[cell viewWithTag:100];
    UILabel * titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel * sourceLabel = (UILabel *)[cell viewWithTag:102];
    
    if(cell.contentView.tag != 55)
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.tag = 55;
        
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, 94)];
        iv.backgroundColor = [UIColor lightGrayColor];
        iv.tag = 100;
        [cell.contentView addSubview:iv];
        
        titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        titleLabel.frame = CGRectMake(0, CGRectGetMaxY(iv.frame) + 5.f, cell.bounds.size.width, 30);
        titleLabel.text = @"TitleLabel";
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.backgroundColor = cell.backgroundColor;
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        
        sourceLabel = [UILabel new];
        sourceLabel.font = [UIFont systemFontOfSize:12.f];
        sourceLabel.frame = CGRectMake(0, CGRectGetMaxY(iv.frame) + 5.f, cell.bounds.size.width, 30);
        sourceLabel.text = @"SourceLabel";
        sourceLabel.textColor = [UIColor orangeColor];
        sourceLabel.numberOfLines = 1;
        sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        sourceLabel.backgroundColor = cell.backgroundColor;
        sourceLabel.tag = 102;
        [cell.contentView addSubview:sourceLabel];
        
        
        UIView * v = [[UIView alloc] initWithFrame:cell.bounds];
        v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f];
        cell.selectedBackgroundView = v;
    }
    
    OBRecommendation * rec = self.recommendations[indexPath.section][indexPath.row];
    titleLabel.text = rec.content;
    sourceLabel.text = [NSString stringWithFormat:@"(%@)",(rec.source ? rec.source : rec.author)];
    
    titleLabel.frame = CGRectMake(0, CGRectGetMaxY(iv.frame) + 5.f, cell.bounds.size.width, 100.f);
    [titleLabel sizeToFit];
    
    [sourceLabel sizeToFit];
    sourceLabel.frame = CGRectMake(0,0, cell.bounds.size.width, CGRectGetHeight(sourceLabel.frame));
    sourceLabel.frame = CGRectOffset(sourceLabel.bounds, 0, CGRectGetMaxY(titleLabel.frame));
    
    typeof(iv) __weak __iv = iv;
    [OBDemoDataHelper fetchImageWithURL:rec.image.url withCallback:^(UIImage *image) {
        [__iv setImage:image];
    }];
    
    [cell bringSubviewToFront:cell.selectedBackgroundView];
    
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


#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [self.internalCollectionView.collectionViewLayout invalidateLayout];
    [super setFrame:frame];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.internalCollectionView.backgroundColor = backgroundColor;
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
    UIActivityIndicatorView * indy = (UIActivityIndicatorView *)[self.loadMoreFooterView viewWithTag:102];
    
    loading?[indy startAnimating]:[indy stopAnimating];
    [UIView animateWithDuration:.25f animations:^{
        b.alpha = _loading?0:1.f;
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

@end

@interface OBInterstitialClassicVC()
@property (nonatomic, weak) OBInterstitialClassicView * classicView;
@end


// Wrapper to put the interstitial inside a viewControlelr
@implementation OBInterstitialClassicVC

- (OBInterstitialClassicView *)classicView
{
    if(!_classicView)
    {
        OBInterstitialClassicView * v = [[OBInterstitialClassicView alloc] initWithFrame:self.view.bounds];
        _classicView = v;
        [self.view addSubview:v];
    }
    return _classicView;
}

@end










#pragma mark - Removed for now

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    if(section == [self.recommendations count]-1) return CGSizeMake(collectionView.bounds.size.width, 50.f);
//
//    return CGSizeZero;
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    // We do not have a header for this interstitial
//    if(![kind isEqualToString:UICollectionElementKindSectionFooter]) return nil;
//
//    static NSString * ElementIdentifier = @"LoadMoreFooterID";
//    UICollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:ElementIdentifier forIndexPath:indexPath];
//
//    if(indexPath.section != [self.recommendations count]-1)
//    {
//        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        return view;
//    }
//
//    if(![view viewWithTag:100])
//    {
//        // Setup the loadmore header
//        UIView * loadMoreView = [[UIView alloc] initWithFrame:view.bounds];
//        loadMoreView.tag = 100;
//
//        UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
//        b.tag = 101;
//        [b setTitle:@"Load More" forState:UIControlStateNormal];
//        [b setBackgroundColor:[UIColor lightGrayColor]];
//        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        b.frame = CGRectMake(CGRectGetMaxX(loadMoreView.frame) - 100.f, 5.f, 100.f, CGRectGetHeight(loadMoreView.bounds) - 10.f);
//        [loadMoreView addSubview:b];
//        [b addTarget:self action:@selector(fetchNextSetOfRecommendations) forControlEvents:UIControlEventTouchUpInside];
//
//        UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        indy.frame = b.frame;
//        indy.tag = 102;
//        indy.backgroundColor = b.backgroundColor;
//        indy.hidesWhenStopped = YES;
//        [loadMoreView addSubview:indy];
//
//        [view addSubview:loadMoreView];
//        self.loadMoreFooterView = loadMoreView;
//    }
//
//
//    return view;
//}

