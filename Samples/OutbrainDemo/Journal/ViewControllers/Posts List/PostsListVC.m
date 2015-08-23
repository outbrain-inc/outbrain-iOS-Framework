//
//  ArticlesListVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/31/13.
//  Copyright (c) 2013 Mercury Intermedia. All rights reserved.
//

#import "PostsListVC.h"
#import "OBDemoDataHelper.h"
#import "Post.h"

#import <OutbrainSDK/OutbrainSDK.h>

#import "OBRecommendationSlideCell.h"

#import "PostsSwipeVC.h"
#import "OBDemoDataHelper.h"

// How many cells between OB Recommended content
#define OB_INLINE_RECOMMENDATION_INTERVAL   3

@interface PostsListVC ()
{
    OBRecommendation * _tappedRecommendation;
    NSOperationQueue *queue;
}

@property (nonatomic, strong) NSMutableArray * loadedOutbrainRecommendationResponses;
@end

@implementation PostsListVC


#pragma mark - View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadedOutbrainRecommendationResponses = [NSMutableArray array];
    UIRefreshControl * refreshControl = [self refreshControl];
    [refreshControl addTarget:self action:@selector(refreshPostsList) forControlEvents:UIControlEventValueChanged];
    

    UIBarButtonItem *addCookiesButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCookies)];

    UIBarButtonItem *removeCookiesButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearAllCookies)];

    UIBarButtonItem *printCookiesButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(printCookies)];
    
    self.navigationItem.leftBarButtonItem = removeCookiesButton;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addCookiesButton, printCookiesButton, nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.postsData.count == 0)
    {
        [self refreshPostsList];
        [self.tableView setContentOffset:CGPointMake(0, -[self refreshControl].bounds.size.height) animated:YES];
    }
}

#pragma mark - Helpers

/**
 *  Indexes should be 0 -> 2, 1 -> 5, 2 -> 8
 *  T_INDEX = Index in table
 *  W_INDEX = Widget Index
 *  Formula = (`INTERVAL` * `(W_INDEX+1)`) + `W_INDEX` = `T_INDEX`
 *
 **/
- (NSIndexPath *)_indexPathForWidgetIndex:(NSInteger)widgetIndex
{
    NSInteger t_row = (OB_INLINE_RECOMMENDATION_INTERVAL * (widgetIndex+1)) + [_loadedOutbrainRecommendationResponses count];
    NSIndexPath * w_indexPath = [NSIndexPath indexPathForRow:t_row inSection:0];
    return w_indexPath;
}

- (NSInteger)_widgetIndexForIndexPath:(NSIndexPath *)ip
{
    NSInteger widgetIndex = 0;
    
    // Current Row - number of responses loaded up to ip.row
    NSInteger convertedRow = ip.row - ((ip.row / OB_INLINE_RECOMMENDATION_INTERVAL) - 1);
    
    widgetIndex = (convertedRow / OB_INLINE_RECOMMENDATION_INTERVAL);
    
    if((convertedRow % OB_INLINE_RECOMMENDATION_INTERVAL) != 0) return NSNotFound;
    
    return widgetIndex-1;
}

/**
 *  Determines:
 *  1.  If the `indexPath` is the indexPath for a widget (based on the OB_INLINE_RECOMMENDATION_INTERVAL)
 *  2.  If we should load the widget
 **/
- (BOOL)shouldLoadRecommendationsForIndexPath:(NSIndexPath *)indexPath
{
    // If we're less than our threshold return NO;
    if(indexPath.row < OB_INLINE_RECOMMENDATION_INTERVAL) return NO;
    
    // if the next widgetIndex == the indexPath.row for the current indexPath, then we are the next widget
    if([self _widgetIndexForIndexPath:indexPath] != NSNotFound)
    {
        if(_loadedOutbrainRecommendationResponses.count > [self _widgetIndexForIndexPath:indexPath])
        {
            // If the loaded response is an error then we should reload it.  Otherwise it's being loaded
            return [_loadedOutbrainRecommendationResponses[[self _widgetIndexForIndexPath:indexPath]] isKindOfClass:[NSError class]];
        }
        return YES;
    }
    
    return NO;
}

- (void)loadOBContentForIndexPath:(NSIndexPath *)indexPath
{
    __block NSInteger widgetIndex = [self _widgetIndexForIndexPath:indexPath];
    
    if([_loadedOutbrainRecommendationResponses count] <= widgetIndex)
    {
        [_loadedOutbrainRecommendationResponses addObject:[NSNull null]];
    }
    else
    {
        [_loadedOutbrainRecommendationResponses replaceObjectAtIndex:widgetIndex withObject:[NSNull null]];
    }
    
    typeof(self) __weak __self = self;
    Post * p = (Post *)[self.postsData firstObject];
    OBRequest * request = [OBRequest requestWithURL:p.url widgetID:OBDemoWidgetID1 widgetIndex:widgetIndex];
    request.homePageRequest = YES;
    // We like block handlers
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        
        // Check if there was an error.
        if(!response || response.error || response.recommendations.count == 0)
        {
            
            // Replace the object here so we know to reload it later
            [__self.loadedOutbrainRecommendationResponses replaceObjectAtIndex:widgetIndex withObject:[NSError errorWithDomain:@"DIDN'T LOAD" code:400 userInfo:nil]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Finally we got a valid response.  We should go insert the data into the table list
            [__self.loadedOutbrainRecommendationResponses replaceObjectAtIndex:response.request.widgetIndex withObject:response];
            [__self.postsData insertObject:response atIndex:indexPath.row];
            [__self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }];
}

- (BOOL)indexPathIsOBRecommendation:(NSIndexPath *)ip
{
    // If post object at ip isRecommendation
    id p = [self postsData][ip.row];
    
    return [p isKindOfClass:[OBRecommendationResponse class]];
}

- (void)refreshPostsList
{
    NSDate * refreshStart = [NSDate date];
    [[self refreshControl] beginRefreshing];
    
    // Clear out the loaded obRecommendationPosts so we can fetch a different batch
    typeof(self) __weak __self = self;
    [[OBDemoDataHelper defaultHelper] updatePostsWithCallback:^(BOOL contentsUpdated) {
        
        if(contentsUpdated)
        {
            [__self.loadedOutbrainRecommendationResponses removeAllObjects];
            __self.postsData = [[NSMutableArray alloc] initWithArray:[OBDemoDataHelper defaultHelper].posts];
            [__self.tableView reloadData];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                __self.detailVC.currentIndex = 0;
                __self.detailVC.posts = __self.postsData;
                [__self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
        
        NSTimeInterval passedTimeInterval = [[NSDate date] timeIntervalSinceDate:refreshStart];
        CGFloat minWaitTime = 2.f;
        if(passedTimeInterval >= minWaitTime)
            [[__self refreshControl] endRefreshing];
        else
        {
            double delayInSeconds = minWaitTime - passedTimeInterval;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[__self refreshControl] endRefreshing];
            });
        }
    }];
}

- (void)_configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self postsData][indexPath.row];
    
    // Item at index is an recommendation
    if([self indexPathIsOBRecommendation:indexPath] && [cell isKindOfClass:[OBRecommendationSlideCell class]])
    {
        OBRecommendationResponse * res = (OBRecommendationResponse *)item;
        OBRecommendationSlideCell *slideCell = (OBRecommendationSlideCell *)cell;
        
        slideCell.recommendationResponse = res;
        slideCell.widgetDelegate = self;
        
        return;
    }
    
    // Item at index is a post
    Post * post = (Post *)item;
    
    if(cell.selectedBackgroundView.tag != 55)
    {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.tag = 55;
    }
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xf6f6f6);
    cell.textLabel.text = post.title;
    cell.detailTextLabel.text = [post.summary stringByStrippingHTML];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self postsData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ArticleCellID = @"ArticleCellID";
    static NSString * OBRecommendationCellID = @"OBRecommendationSlideCell";
    
    // We will attempt to show an outbrain inline recommended cell every x number of articles.
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[self indexPathIsOBRecommendation:indexPath]?OBRecommendationCellID:ArticleCellID];
    [self _configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dynamically determine/load outbrain recommendations for a given indexPath.
    if([self shouldLoadRecommendationsForIndexPath:indexPath])
    {
        [self loadOBContentForIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Here we need to update the current item on the detail VC
        self.detailVC.currentIndex = indexPath.row;
    }
}


#pragma mark - OBWidgetView delegate

- (void)widgetView:(id<OBWidgetViewProtocol>)widgetView tappedRecommendation:(OBRecommendation *)recommendation
{
    // User tapped a recommendation   
    if (recommendation.isSameSource) {
        // url here
        NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:recommendation];
        typeof(self) __weak __self = self;
        __block UIAlertView * loadingAlert = [[UIAlertView alloc] initWithTitle:@"Fetching Content" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [loadingAlert show];
        [[OBDemoDataHelper defaultHelper] fetchPostForURL:url withCallback:^(id postObject, NSError *error) {
            [loadingAlert dismissWithClickedButtonIndex:-1 animated:YES];
            if(postObject)
            {
                PostsSwipeVC * postsVc = [__self.view.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"postsSwipeVC"];
                [self.navigationController pushViewController:postsVc animated:YES];
                postsVc.posts = @[postObject];
            }
        }];
    }
    else {
        [self performSegueWithIdentifier:@"ShowRecommendedContent" sender:recommendation];
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue destinationViewController] isKindOfClass:[PostsSwipeVC class]])
    {
        self.title = @" ";
        PostsSwipeVC * destination = (PostsSwipeVC *)[segue destinationViewController];
        destination.posts = [[OBDemoDataHelper defaultHelper] posts];
        
        // We need to conver the index since we're not passing on our oubrain recommendations
        NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Post * selectedPost = [self postsData][selectedIndexPath.row];
        destination.currentIndex = [destination.posts indexOfObject:selectedPost];
    }
    else if([segue.identifier isEqualToString:@"ShowRecommendedContent"])
    {
        // This is our segue for displaying a tapped recomendation
        UINavigationController * nav = [segue destinationViewController];
        [[nav topViewController] setValue:sender forKey:@"recommendation"];
    }
}


- (void)addCookies {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"DEMO_COOKIE" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"YUM" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"www.DEMO.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"www.DEMO.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)printCookies {
    NSString *cookiesDomains = @"";
    NSString *cookiesNames = @"";
    
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        cookiesNames = [cookiesNames stringByAppendingString:cookie.name];
        cookiesNames = [cookiesNames stringByAppendingString:@"||"];
        cookiesDomains = [cookiesDomains stringByAppendingString:cookie.domain];
        cookiesDomains = [cookiesDomains stringByAppendingString:@"||"];
    }
    
    [[[UIAlertView alloc] initWithTitle:@"COOKIES" message:[NSString stringWithFormat:@"domains: %@\n names:%@", cookiesDomains, cookiesNames] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (IBAction)clearAllCookies {
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
