//
//  OBIntersitialHeroView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/18/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBInterstitialHeroView.h"


#define INDY_TAG    102030
@interface OBInterstitialHeroViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * sourceLabel;

@property (nonatomic, assign, getter = isHeroUnit) BOOL heroUnit;
@end

@interface OBInterstitialHeroView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * internalCollectionView;
@property (nonatomic, strong) UIView * bottomPTRView;
@property (nonatomic, strong) NSMutableArray * recommendations;

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@end

@implementation OBInterstitialHeroView


#pragma mark - Initialize

- (void)commonInit
{
    UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    cv.bounces = YES;
    cv.delegate = self;
    cv.dataSource = self;
    cv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [cv registerClass:[OBInterstitialHeroViewCell class] forCellWithReuseIdentifier:@"RecommendationCell"];
    
    [self addSubview:cv];
    self.internalCollectionView = cv;
    
    self.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.000];
    self.recommendations = [NSMutableArray array];
    
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
    
    [self.internalCollectionView addSubview:self.bottomPTRView];
    
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Fetching

- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *))callback
{
    
    BOOL (^ReturnHandler)(UIImage *) = ^(UIImage *returnImage) {
        if(!returnImage) return NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(returnImage);
        });
        return YES;
    };
    
    __block UIImage * responseImage = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * key = @([url.absoluteString hash]).stringValue;
        // Next check if the image is on disk.  If it is then we'll go ahead and add it to the cache and return from the cache
        NSString * cachesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.ob.images"];
        NSFileManager * fm = [[NSFileManager alloc] init];
        [fm createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * diskCachePath = [cachesDir stringByAppendingPathComponent:key];
        
        // We have this on disk.
        responseImage = [UIImage imageWithContentsOfFile:diskCachePath];
        if(!ReturnHandler(responseImage))
        {
            // Fetch the image
            NSData * d = [NSData dataWithContentsOfURL:url];
            if(d)
            {
                responseImage = [UIImage imageWithData:d];
                ReturnHandler(responseImage);
                [d writeToFile:diskCachePath atomically:YES];
            }
        }
        
    });
}

- (void)fetchNextSetOfRecommendations
{
    self.loading = YES;
    typeof(self) __weak __self = self;
    __block NSDate * d = [NSDate date];
    [Outbrain fetchRecommendationsForRequest:self.request withCallback:^(OBRecommendationResponse *response) {
        
        // Show loading view for delayInSeconds
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:d];
        double delayInSeconds = .5f - interval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if([__self.widgetDelegate respondsToSelector:@selector(widgetViewDidLoadRecommendations:)])
                [__self.widgetDelegate widgetViewDidLoadRecommendations:__self];
            
            [UIView animateWithDuration:.25f animations:^{
                __self.bottomPTRView.alpha = 0.f;
            } completion:^(BOOL finished) {
                __self.bottomPTRView.alpha = 1.f;
                [__self.bottomPTRView removeFromSuperview];
            }];
            
            if(response && response.recommendations.count > 0)
            {
                NSInteger beginIndex = [__self.recommendations count];
                NSMutableArray * indexPaths = [NSMutableArray array];
                [__self.recommendations addObjectsFromArray:response.recommendations];
                
                if(__self.recommendations.count % 2 == 0) [__self.recommendations removeLastObject];
                
                for(NSInteger i = beginIndex; i < __self.recommendations.count; i++)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [__self.internalCollectionView insertItemsAtIndexPaths:indexPaths];
                [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:.01]];
            }
            
            // Finally reset the contentInsets
            void (^ContentInsetBlock)() = ^{
                UIEdgeInsets insets = __self.internalCollectionView.contentInset;
                CGFloat diff = (response.recommendations.count == 0)? 0 : insets.bottom;
                insets.bottom = 0.f;
                __self.internalCollectionView.contentInset = insets;
                __self.internalCollectionView.contentOffset = CGPointMake(0, __self.internalCollectionView.contentOffset.y+diff);
                if(__self.internalCollectionView.contentSize.height < CGRectGetMaxY(__self.bounds))
                {
                    [__self fetchNextSetOfRecommendations];
                }
            };
            
            if(response.recommendations.count == 0)
            {
                // Here we need to animate the content inset since we did not get
                // any recommendations.  Otherwise there will be some jumping
                [UIView animateWithDuration:.2f animations:^{
                    ContentInsetBlock();
                }];
            }
            else
            {
                // No need to animate since we're adding to our content
                ContentInsetBlock();
                
                // Only increase our widget index if the request succeeded
                __self.request.widgetIndex += 1;
            }
            
            // Always reset loading to no
            __self.loading = NO;
        });
        
    }];
}


#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.recommendations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"RecommendationCell";
    OBInterstitialHeroViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    OBRecommendation * recommendation = self.recommendations[indexPath.row];
    
    cell.heroUnit = YES;
    cell.titleLabel.text = recommendation.content;
    cell.sourceLabel.text = [NSString stringWithFormat:@"(%@)",recommendation.author?:recommendation.source];
    typeof(cell.imageView) __weak __iv = cell.imageView;
    [self fetchImageForURL:recommendation.image.url withCallback:^(UIImage *image) {
        [__iv setImage:image];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // Allow time for the press animation to finish
    double delayInSeconds = .25f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(self.recommendationTapHandler)
        {
            self.recommendationTapHandler(self.recommendations[indexPath.row]);
        }
        
        if([self.widgetDelegate respondsToSelector:@selector(widgetView:tappedRecommendation:)])
        {
            [self.widgetDelegate widgetView:self tappedRecommendation:self.recommendations[indexPath.row]];
        }
    });
}


#pragma mark - Collection Size

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, 175.f);
}


#pragma mark - Bottom Pull to Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.loading) return;
    CGFloat pullToRefreshPadding = self.bottomPTRView.bounds.size.height;
    
    if(!self.bottomPTRView.superview)
    {
        [scrollView addSubview:self.bottomPTRView];
    }
    self.bottomPTRView.frame = CGRectOffset(self.bottomPTRView.bounds, 0, scrollView.contentSize.height);
    UILabel * loadingTextLabel = (UILabel *)[self.bottomPTRView viewWithTag:101];
    if (CGRectGetMaxY(scrollView.bounds) > scrollView.contentSize.height + pullToRefreshPadding)
    {
        if(scrollView.isDragging)
        {
            loadingTextLabel.text = @"Let go to load more";
        }
        else
        {
            self.loading = YES;
            [UIView animateWithDuration:.2f animations:^{
                UIEdgeInsets inset = scrollView.contentInset;
                inset.bottom += pullToRefreshPadding;
                scrollView.contentInset = inset;
            } completion:^(BOOL finished) {
                [self fetchNextSetOfRecommendations];
            }];
        }
    }
    else
    {
        loadingTextLabel.text = @"Pull up to load more";
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
    
    // Reset the the data to blank
    [self.recommendations removeAllObjects];
    [self.internalCollectionView reloadData];
    
    // Fetch
    [self fetchNextSetOfRecommendations];
}

- (void)setLoading:(BOOL)loading
{
    if(_loading == loading) return;
    _loading = loading;
    
    UILabel * loadingMoreTextLabel = (UILabel *)[self.bottomPTRView viewWithTag:101];
    loadingMoreTextLabel.text = _loading ? @"Loading..." : @"Push up to load more";
    
    UIActivityIndicatorView * indy = (UIActivityIndicatorView *)[self.bottomPTRView viewWithTag:INDY_TAG];
    _loading?[indy startAnimating]:[indy stopAnimating];
    
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


#pragma mark - Getters

- (UIView *)bottomPTRView
{
    if(!_bottomPTRView)
    {
        UIView * bottomPTRView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 80.f)];
        
        UILabel * l = [UILabel new];
        l.tag = 101;
        l.textAlignment = NSTextAlignmentCenter;
        l.frame = bottomPTRView.bounds;
        l.backgroundColor = [UIColor clearColor];
        l.text = @"Push up to load more";
        l.font = [UIFont boldSystemFontOfSize:22.f];
        l.textColor = [UIColor orangeColor];
        [l sizeToFit];
        l.center = CGPointMake(bottomPTRView.bounds.size.width/2.f, bottomPTRView.bounds.size.height/2.f);
        [bottomPTRView addSubview:l];
        
        UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indy.tag = INDY_TAG;
        indy.hidesWhenStopped = YES;
        indy.center = CGPointMake(CGRectGetMaxX(l.frame) + CGRectGetMidX(indy.bounds), l.center.y);
        [bottomPTRView addSubview:indy];
        
        _bottomPTRView = bottomPTRView;
    }
    return _bottomPTRView;
}

@end


@interface OBInterstitialHeroViewCell()
@property (nonatomic, strong) UIView * overlay;
@property (nonatomic, strong) CALayer * insetShadowLayer;

@end


@implementation OBInterstitialHeroViewCell
{
    UIBezierPath * _highlightedShadowPath;
    UIBezierPath * _normalShadowPath;
}

#pragma mark - Initialize

- (void)commonInit
{
    UIImageView * iv = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [self.contentView addSubview:iv];
    self.imageView = iv;
    
    CGFloat leftMargin = 10.f;
    
    CGRect r = self.contentView.bounds;
    
    
    UIView * overlay = [[UIView alloc] initWithFrame:r];
    overlay.tag = 100.f;
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
    overlay.userInteractionEnabled = NO;
    [self.contentView addSubview:overlay];
    self.overlay = overlay;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, leftMargin, self.contentView.bounds.size.width-(leftMargin*2.f), self.contentView.bounds.size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.contentMode = UIViewContentModeBottom;
    titleLabel.numberOfLines = 4;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel * sourceLabel = [UILabel new];
    sourceLabel.backgroundColor = [UIColor clearColor];
    sourceLabel.font = [UIFont systemFontOfSize:12.f];
    sourceLabel.textColor = [UIColor colorWithRed:0.933 green:0.506 blue:0.000 alpha:1.000];
    [self.contentView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    
    CALayer * shadowLayer = [CALayer layer];
    shadowLayer.masksToBounds = YES;
    shadowLayer.frame = overlay.bounds;
    
    shadowLayer.shouldRasterize = YES;
    shadowLayer.contentsScale = [UIScreen mainScreen].scale;
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
    shadowLayer.shadowOpacity = 1.f;
    shadowLayer.shadowRadius = 5.f;
    
    [overlay.layer addSublayer:shadowLayer];
    self.insetShadowLayer = shadowLayer;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25f];
    [self.contentView insertSubview:self.selectedBackgroundView aboveSubview:iv];
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Helpers

- (UIBezierPath *)_insetShadowPathWithRadius:(CGFloat)radius
{
    CGRect r = CGRectInset(self.contentView.bounds, -radius, -radius);
    
	UIBezierPath * path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(r), CGRectGetMinY(r), CGRectGetMaxX(r), radius*2.f)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMaxX(r) - (radius*2.f), CGRectGetMinY(r), radius*2.f, CGRectGetMaxY(r))]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(r), CGRectGetMaxY(r) - (radius*2.f), CGRectGetMaxX(r), radius*2.f)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(r),CGRectGetMinY(r),radius*2.f,CGRectGetMaxY(r))]];
    [path closePath];
    
    return path;
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _normalShadowPath = [self _insetShadowPathWithRadius:5.f];
    _highlightedShadowPath = [self _insetShadowPathWithRadius:10.f];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = self.contentView.bounds;
    _insetShadowLayer.frame = self.contentView.bounds;
    _overlay.frame = self.contentView.bounds;
    _insetShadowLayer.shadowPath = _normalShadowPath.CGPath;
    [CATransaction commit];
    
    CGFloat leftMargin = 10.f;
    
    _titleLabel.font = [UIFont boldSystemFontOfSize:self.isHeroUnit?20.f:15.f];
    
    CGRect r = _titleLabel.frame;
    r.origin = CGPointMake(leftMargin, leftMargin);
    r.size.width = self.contentView.bounds.size.width - (leftMargin*2.f);
    r.size.height = MAXFLOAT;
    r.size.height = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:r.size lineBreakMode:_titleLabel.lineBreakMode].height;
    _titleLabel.frame = r;
    
    r = _sourceLabel.bounds;
    r.size.width = self.contentView.bounds.size.width - (leftMargin*2.f);
    r.size.height = 30.f;
    _sourceLabel.bounds = r;
    
    if(self.isHeroUnit)
    {
        _titleLabel.center = CGPointMake(roundf(self.contentView.bounds.size.width/2.f), roundf(self.contentView.bounds.size.height/2.f) - 20.f);
        _sourceLabel.center = CGPointMake(CGRectGetMinX(_titleLabel.frame) + CGRectGetMidX(_sourceLabel.bounds), CGRectGetMidY(_sourceLabel.bounds) + CGRectGetMaxY(_titleLabel.frame));
    }
    else
    {
        _sourceLabel.center = CGPointMake(CGRectGetMidX(_sourceLabel.bounds) + leftMargin, CGRectGetMaxY(self.contentView.bounds) - CGRectGetMidY(_sourceLabel.bounds) - leftMargin);
    }
}


#pragma mark - Highlight

- (void)setHighlighted:(BOOL)highlighted
{
    CGFloat duration = .1f;
    
    CGPathRef toPathRef = [(highlighted?[self _insetShadowPathWithRadius:10.f]:_normalShadowPath) CGPath];
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = duration;
    theAnimation.fromValue = (__bridge id)self.insetShadowLayer.shadowPath;
    theAnimation.toValue = (__bridge id)toPathRef;
    [self.insetShadowLayer addAnimation:theAnimation forKey:@"shadowPath"];
    self.insetShadowLayer.shadowPath = toPathRef;
    
    self.selectedBackgroundView.alpha = (highlighted?0.f:1.f);
    [UIView animateWithDuration:duration animations:^{
        self.selectedBackgroundView.alpha = (highlighted?1.f:0.f);
    }];
    
    [super setHighlighted: highlighted];
}

@end
