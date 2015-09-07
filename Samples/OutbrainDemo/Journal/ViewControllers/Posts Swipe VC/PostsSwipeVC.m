//
//  PostsSwipeVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/2/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "PostsSwipeVC.h"
#import "PostViewCell.h"
#import "OBParalaxTitleView.h"
#import "Post.h"

#import "OBInterstitialClassicView.h"
#import "OBInterstitialHeroGridView.h"

#import "OBDemoDataHelper.h"
#import "JLoadingView.h"
#import "OBAppDelegate.h"
#import "TopBoxPostViewCell.h"

@interface PostsSwipeVC () <OBWidgetViewDelegate,OBInterstitialViewDelegate>
@end


@implementation PostsSwipeVC

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define STATUS_BAR_HEIGHT 20.0


- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentIndex = NSNotFound;
}

#pragma mark - View Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.currentIndex != NSNotFound) {
        [self.collectionView layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    }
    
    self.collectionView.scrollsToTop = NO;
    
    // We don't want to be able to backswipe while we're in here
    if ([self.navigationController respondsToSelector:NSSelectorFromString(@"interactivePopGestureRecognizer")]) {
        [self.navigationController setValue:@NO forKeyPath:@"interactivePopGestureRecognizer.enabled"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

#pragma mark - Helpers

// Returns whether or not the given `index` is a post
// or a recommendation slog
- (BOOL)_itemAtIndexIsRecommendation:(NSInteger)index
{
    if(index >= [self posts].count) return NO;
    return ![[self posts][index] isKindOfClass:[Post class]];
}

- (BOOL)_itemAtIndexIsTopBox:(NSInteger)index
{
    if(index >= [self posts].count) return NO;
    return (index % 2);
}

- (NSInteger)_actualPostsCount
{
    NSInteger actualPostsCount = 0;
    for(Post * p in self.posts)
    {
        if([p isKindOfClass:[Post class]]) actualPostsCount++;
    }
    return actualPostsCount;
}

// Return the index for the actual post item given
// an `index` which includes the recommendation count
- (NSInteger)_postIndexForIndex:(NSInteger)index
{
    if(index < INTERSTITIAL_FREQUENCY) return index;
    return index - (index / INTERSTITIAL_FREQUENCY);
}


#pragma mark - Setters

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if(_currentIndex == currentIndex) return;
    
    // Sanity
    if(currentIndex >= [self posts].count) return;
    if(currentIndex < 0) return;
    
    _currentIndex =
    _titleView.currentIndex = currentIndex; 
    
    // Load the post only when we get to this page.
    // Otherwise we're potentially loading 3 webviews at once.  No Mi Gusta
    PostViewCell * cell = (PostViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
    for(UICollectionViewCell * cell in [self.collectionView visibleCells])
    {
        if([cell isKindOfClass:[PostViewCell class]]) {
        
            // Unset this so that we can allow scrollsToTop
            [(PostViewCell *)cell textView].scrollsToTop = NO;
        }
        else if([cell isKindOfClass:[TopBoxPostViewCell class]]) {
            [(TopBoxPostViewCell *)cell mainScrollView].scrollsToTop = NO;
        }
    }
    
    if(cell && [cell respondsToSelector:@selector(delayedContentLoad)])
    {
        [cell delayedContentLoad];
    }
}

- (void)setPosts:(NSArray *)posts
{
if([posts isEqual:_posts]) return;
    
    
    NSMutableArray * tmp = [posts mutableCopy];
    __block NSMutableArray * titles = [NSMutableArray array];
    [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *idxNum = @(idx+1);
        [titles addObject:[NSString stringWithFormat:@"Article %@", idxNum]];
    }];
    
    // Insert interstitial slots based on frequency
    NSInteger expectedInterstitialCount = [posts count] / INTERSTITIAL_FREQUENCY;
    
    for(NSInteger i = 0; i < expectedInterstitialCount; i++)
    {
        NSInteger convertedIndex = (INTERSTITIAL_FREQUENCY * (i+1)) + i;
        static NSString * recommendationTitle = @"Recommended Content";
        [titles insertObject:recommendationTitle atIndex:convertedIndex];
        [tmp insertObject:@{@"title":recommendationTitle} atIndex:convertedIndex];
    }
    
    
    _posts = [tmp copy];
    if ([posts count] > 1) {
        _titleView.pageControl.numberOfPages = _posts.count;
    }
    self.titleView.titles = titles;
    [self.collectionView reloadData];
}


#pragma mark - CollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self posts].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * PostCellID = @"PostCellID";
    static NSString * TopBoxPostCellID = @"TopBoxPostCellID";
    static NSString * RecommendationCellID = @"RecommendationCellID";
    
    BOOL indexIsRecommendation = [self _itemAtIndexIsRecommendation:indexPath.row];
    BOOL indexIsTopBox = [self _itemAtIndexIsTopBox:indexPath.row];
    
    UICollectionViewCell *cell;
    
    if (!indexIsRecommendation && indexIsTopBox) {
        cell = (TopBoxPostViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TopBoxPostCellID forIndexPath:indexPath];
    }
    else {
        cell = (PostViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:(indexIsRecommendation ? RecommendationCellID : PostCellID) forIndexPath:indexPath];
    }
    if(!indexIsRecommendation)
    {
        if (indexIsTopBox) {
            ((TopBoxPostViewCell *)cell).post = [self posts][indexPath.row];
            ((TopBoxPostViewCell *)cell).topBoxView.widgetDelegate = self;
            if(indexPath.row == self.currentIndex)
            {
                [((TopBoxPostViewCell *)cell) delayedContentLoad];
            }
        }
        else {
            ((PostViewCell *)cell).post = [self posts][indexPath.row];
            ((PostViewCell *)cell).outbrainClassicView.widgetDelegate = self;
            ((PostViewCell *)cell).outbrainHoverView.widgetDelegate = self;
            if(indexPath.row == self.currentIndex)
            {
                [((TopBoxPostViewCell *)cell) delayedContentLoad];
            }
        }
    }
    else
    {
        // Recommendation slot
        UIView < OBInterstitialViewProtocol > *interstitialView = (OBInterstitialHeroGridView *)[cell.contentView viewWithTag:200];
        if(!interstitialView)
        {
            CGRect frame = self.view.frame;
            frame.origin = CGPointMake(0, 0);
            interstitialView = [[OBInterstitialHeroGridView alloc] initWithFrame:frame];
            interstitialView.tag = 200;
        }
        // In case we want to put an classid interstitial instead
        
        interstitialView.request = [OBRequest requestWithURL:[(Post *)self.posts[indexPath.row-1] url] widgetID:OBDemoWidgetID3];
        interstitialView.widgetDelegate = self;
        [cell.contentView addSubview:interstitialView];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        return self.collectionView.frame.size;
    }
    else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        
        if (screenHeight > self.collectionView.frame.size.height) {
            return self.collectionView.frame.size;
        }
        else {
            return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height - self.navigationController.navigationBar.bounds.size.height - STATUS_BAR_HEIGHT);            
        }
    }
    
    
    //return self.collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}


#pragma mark - ScrollView Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if(fmod(offset, 1.f) == 0.f || fabs(_currentIndex - offset) >= 1) {
        // set current index
        [self setCurrentIndex:roundf(offset)];
    }
    
    [_titleView setCurrentOffset:offset];
}


#pragma mark - Widget View Delegate

- (void)widgetViewDidLoadRecommendations:(id<OBInterstitialViewProtocol>)widgetView
{
    
}

- (void)widgetView:(UIView<OBWidgetViewProtocol> *)widgetView tappedRecommendation:(OBRecommendation *)recommendation
{
    if(recommendation.isSameSource)
    {
        // url here
        NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:recommendation];
        typeof(self) __weak __self = self;
        __block UIAlertView * loadingAlert = [[UIAlertView alloc] initWithTitle:@"Fetching Content" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [loadingAlert show];
        [[OBDemoDataHelper defaultHelper] fetchPostForURL:url withCallback:^(id postObject, NSError *error) {
            [loadingAlert dismissWithClickedButtonIndex:-1 animated:YES];
            if(postObject)
            {
                NSMutableArray * tmp = [__self.posts mutableCopy];
                
                // Put in the current post object
                NSInteger index = __self.currentIndex + (__self.currentIndex == [__self.posts count] - 1 ? 0 : 1);
                
                // If our next page is an interstitial page.  Then we should do all of our logic past that.
                if(![tmp[index] isKindOfClass:[Post class]])
                    index += 1;
                
                id obj = [tmp objectAtIndex:index];
                NSInteger originalItemIndex = [tmp indexOfObject:postObject];
                
                [tmp replaceObjectAtIndex:index withObject:postObject]; // Replace the next page with the post
                
                // If the postObject was already in the list, then we'll take the object that was in
                // the next position and exchange it with the original post
                if(originalItemIndex != NSNotFound)
                {
                    [tmp replaceObjectAtIndex:originalItemIndex withObject:obj];
                }
                else
                {
                    [tmp addObject:obj];
                }
                
                // Remove all the interstitial tmp components if any
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@",[NSDictionary class]];
                [tmp removeObjectsInArray:[tmp filteredArrayUsingPredicate:predicate]];
                
                // Finally reset the posts
                [__self setPosts:[tmp copy]];
                
                
                // Now scroll over to the new native content
                [__self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[__self.posts indexOfObject:postObject] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
            else
            {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [a show];
            }
        }];
        
        return;
    }
    
    [self performSegueWithIdentifier:@"ShowRecommendedContent" sender:recommendation];
}

- (void)widgetViewTappedBranding:(UIView<OBWidgetViewProtocol> *)widgetView
{
    OBAppDelegate * appDelegate = (OBAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showOutbrainAbout];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowRecommendedContent"])
    {
        UINavigationController * nav = [segue destinationViewController];
        [[nav topViewController] setValue:sender forKey:@"recommendation"];
    }
}


@end
