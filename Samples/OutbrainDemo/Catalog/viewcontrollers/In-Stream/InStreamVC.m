//
//  InStreamVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/31/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "InStreamVC.h"

@implementation InStreamVC


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = @"In-Stream";

    // Fetch a response
    __block UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Getting Outbrain Recommendations" message:@"[Outbrain fetchRecommendations" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [a show];
    typeof(self) __weak __self = self;
    [Outbrain fetchRecommendationsForRequest:[OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID] withCallback:^(OBRecommendationResponse *response) {
        
        // This will always comeback on the main thread
        __self.response = response;
        [__self.tableView reloadData];
        [a dismissWithClickedButtonIndex:-1 animated:YES];
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.response.recommendations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * RecommendationCellID = @"RecommendationCellID";
    
    // Return the proper cell depending on index
    OBRecommendationSlideCell *cell = (OBRecommendationSlideCell *)[tableView dequeueReusableCellWithIdentifier:RecommendationCellID forIndexPath:indexPath];
    
    // Pass the response we received from the sdk to the cell.
    [cell setRecommendationResponse:self.response];
    [cell setWidgetDelegate:self];
    
    return cell;
}


#pragma mark - OBWidgetViewDelegate

- (void)widgetView:(UIView<OBWidgetViewProtocol> *)widgetView tappedRecommendation:(OBRecommendation *)recommendation
{
    // This recommendations was tapped.    
    NSURL * url = [Outbrain getUrl:recommendation];
    
    // Now we have a url that we can show in a webview, or if it's a piece of our native content
    // Then we can inspect [url hash] to get the mobile_id
    
    NSString * message = [NSString stringWithFormat:@"User tapped recommendation.  Need to present content for this url %@", [url absoluteString]];
    
    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Recommendation Tapped!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [a show];
}


@end
