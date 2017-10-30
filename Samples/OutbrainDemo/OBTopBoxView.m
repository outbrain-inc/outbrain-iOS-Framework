//
//  OBHoverView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBTopBoxView.h"
#import <OutbrainSDK/OBRecommendationResponse.h>
#import "OBDemoDataHelper.h"
#import "OBRecommendationSlideCell.h"


@interface OBTopBoxView () <UITableViewDataSource, UITableViewDelegate>

/**
 *  Internal scroll container
 **/
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation OBTopBoxView


#pragma mark - Initialize

- (void)commonInit
{
    self.backgroundColor = [UIColorFromRGB(0xF4F4F4) colorWithAlphaComponent:.95f];
    
    _tableView = [[UITableView alloc] initWithFrame:[self hoverBounds]];
    _tableView.backgroundColor = [UIColor redColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
    
//    typeof(self) __weak __self = self;
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
////        [__self.tableView invalidateIntrinsicContentSize];
//    }];
    
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }

- (void)brandingTapAction:(id)sender
{
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}


#pragma mark - Getters

- (CGRect)hoverBounds
{
    // We want to subtract 100 so that we have some padding when we're pulling up.
    // This simulates the control center on ios
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}


#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    CGRect bounds = frame;
    bounds.origin = CGPointZero;
    BOOL boundsChange = !CGRectEqualToRect(bounds, self.bounds);
    [super setFrame: frame];
    self.tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(boundsChange) [self.tableView reloadData];
}

- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    if([_recommendationResponse isEqual:recommendationResponse]) return;
    
    _recommendationResponse = recommendationResponse;
    
    [self.tableView reloadData];
//    [self.internalCollectionView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 10) animated:NO];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *RecommendationCellID = @"Cell";
    
    OBRecommendationSlideCell *cell = (OBRecommendationSlideCell *)[tableView dequeueReusableCellWithIdentifier:RecommendationCellID];
    if (!cell) {
        cell = [[OBRecommendationSlideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecommendationCellID];
    }
    
    // Pass the response we received from the sdk to the cell.
    [cell setRecommendationResponse:self.recommendationResponse];
    [cell setWidgetDelegate:self.widgetDelegate];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
    
    if([self.widgetDelegate respondsToSelector:@selector(widgetView:tappedRecommendation:)])
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
}

#pragma mark - Helpers

@end

