//
//  PostsListVC.m
//  OutbrainDemo
//
//  Created by Oded Regev on 11/1/17.
//  Copyright (c) 2017 Outbrain inc. All rights reserved.
//


#import "PostsListVC.h"
#import "OBDemoDataHelper.h"
#import "Post.h"
#import "OBAppDelegate.h"
#import "PostPreviewCell.h"

#import <OutbrainSDK/OutbrainSDK.h>

#import "OBRecommendationSlideCell.h"

#import "PostsSwipeVC.h"
#import "OBDemoDataHelper.h"

// How many cells between OB Recommended content
#define OB_INLINE_RECOMMENDATION_INTERVAL   3
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


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
    
    [self setupNavbar];
    self.tableView.estimatedRowHeight = 100.0;
    self.loadedOutbrainRecommendationResponses = [NSMutableArray array];
    UIRefreshControl * refreshControl = [self refreshControl];
    [refreshControl addTarget:self action:@selector(refreshPostsList) forControlEvents:UIControlEventValueChanged];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.postsData.count == 0)
    {
        [self refreshPostsList];
        [self.tableView setContentOffset:CGPointMake(0, -[self refreshControl].bounds.size.height) animated:YES];
    }
}

#pragma mark - Nav bar
- (void) setupNavbar {
    // Took advice from: https://stackoverflow.com/a/13341629/583425
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 30)];
    view.backgroundColor = [UIColor clearColor];

    UIImage *btnImage = [UIImage imageNamed:@"recommendedbylarge"];
    UIButton *aboutOutbrainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutOutbrainButton.frame = view.frame;
    [aboutOutbrainButton setImage:btnImage forState:UIControlStateNormal];
    aboutOutbrainButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [aboutOutbrainButton addTarget:self action:@selector(showOutbrainAbout) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:aboutOutbrainButton];
    
    self.navigationItem.titleView = view;
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
    
    
    [self fetchOutbrainRecFor:indexPath];
    
}

-(void) fetchOutbrainRecFor:(NSIndexPath *)indexPath {
    __block NSInteger widgetIndex = [self _widgetIndexForIndexPath:indexPath];
    typeof(self) __weak __self = self;
    Post * p = (Post *)[self.postsData firstObject];
    OBRequest * request = [OBRequest requestWithURL:p.url widgetID:OBDemoWidgetID1 widgetIndex:widgetIndex];
    
    
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
    NSLog(@"refreshPostsList...");
    NSDate * refreshStart = [NSDate date];
    [[self refreshControl] beginRefreshing];
    
    // Clear out the loaded obRecommendationPosts so we can fetch a different batch
    typeof(self) __weak __self = self;
    [[OBDemoDataHelper defaultHelper] updatePostsInViewController:self withCallback:^(BOOL updated) {
        if (updated)
        {
            NSLog(@"refreshPostsList --> has new posts");
            [__self.loadedOutbrainRecommendationResponses removeAllObjects];
            __self.postsData = [[NSMutableArray alloc] initWithArray:[OBDemoDataHelper defaultHelper].posts];
            dispatch_after(0, dispatch_get_main_queue(), ^(void){
                [__self.tableView reloadData];
                [__self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

            });
        }
        
        NSTimeInterval passedTimeInterval = [[NSDate date] timeIntervalSinceDate:refreshStart];
        CGFloat minWaitTime = 2.f;
        if (passedTimeInterval >= minWaitTime)
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
    if ([self indexPathIsOBRecommendation:indexPath] && [cell isKindOfClass:[OBRecommendationSlideCell class]])
    {
        OBRecommendationResponse * res = (OBRecommendationResponse *)item;
        OBRecommendationSlideCell *slideCell = (OBRecommendationSlideCell *)cell;
        
        Post * p = (Post *)[self.postsData firstObject];
        slideCell.recommendationResponse = res;
        slideCell.widgetDelegate = self;
        [slideCell setUrl:p.url andWidgetId:OBDemoWidgetID1];
        
        return;
    }
    
    // Item at index is a post
    Post * post = (Post *)item;
    
    PostPreviewCell *postPreviewCell = (PostPreviewCell *)cell;
    postPreviewCell.postTitleLabel.text = post.title;
    postPreviewCell.postPreviewLabel.text = [post.summary stringByStrippingHTML];
    
    
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
    NSString *identifier = [self indexPathIsOBRecommendation:indexPath] ? OBRecommendationCellID : ArticleCellID;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: identifier];
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
    [self performSegueWithIdentifier:@"readPostSegue" sender:self];

}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self indexPathIsOBRecommendation:indexPath]) {
        return 100.0;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

#pragma mark - OBWidgetView delegate

- (void)widgetView:(id<OBWidgetViewProtocol>)widgetView tappedRecommendation:(OBRecommendation *)recommendation
{
    // First report the click to the SDK and receive the URL to open.
    NSURL * url = [Outbrain getUrl:recommendation];
    
    
    // User tapped a recommendation   
    if (recommendation.isPaidLink == NO) { // Organic
        typeof(self) __weak __self = self;
        __block UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle: @"Fetching Content"
                                                      message: @""
                                                      preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
    
        [[OBDemoDataHelper defaultHelper] fetchPostForURL:url withCallback:^(id postObject, NSError *error) {
            [alertController dismissViewControllerAnimated:YES completion:^{
                [__self handleFetchPostResponse:postObject error:error];
            }];
        }];
    }
    else {
        [self openUrlInSafariVC: url];
    }
}

- (void)widgetViewTappedBranding:(UIView<OBWidgetViewProtocol> *)widgetView {
    OBAppDelegate * appDelegate = (OBAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showOutbrainAbout];
}

-(void) handleFetchPostResponse:(id)postObject error:(NSError *)error {
    if (error != nil) {
        UIAlertController *alertController = [UIAlertController
                           alertControllerWithTitle: @"Error"
                           message: error.userInfo[NSLocalizedDescriptionKey]
                           preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertController animated:YES completion:nil];
        // dismiss the alert controller after 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion: nil];
        });
    }
    else if (postObject)
    {
        PostsSwipeVC * postsVc = [self.view.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"postsSwipeVC"];
        [self.navigationController pushViewController:postsVc animated:YES];
        postsVc.posts = @[postObject];
        postsVc.currentIndex = 0;
    }
    
}

#pragma mark - IBAction
- (IBAction)showOutbrainAbout {
    OBAppDelegate * appDelegate = (OBAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showOutbrainAbout];
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
}


#pragma mark - SFSafariViewController + SFSafariViewControllerDelegate

- (void) openUrlInSafariVC:(NSURL *)url {
    SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
    sf.delegate = self;
    [self.navigationController presentViewController:sf animated:YES completion:nil];
}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    NSLog(@"safariViewController didCompleteInitialLoad");
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    NSLog(@"safariViewController safariViewControllerDidFinish");
}


@end
