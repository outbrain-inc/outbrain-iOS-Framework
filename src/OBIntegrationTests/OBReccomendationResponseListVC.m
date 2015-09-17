//
//  OBReccomendationResponseListVC.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/30/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBReccomendationResponseListVC.h"
#import <QuartzCore/CALayer.h>

@interface OBReccomendationResponseListVC () <UIAlertViewDelegate>
@property (nonatomic, strong) NSCache * imageCache;
@end

@implementation OBReccomendationResponseListVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.imageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recommendationResponse.recommendations.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OBRecommendation *r = _recommendationResponse.recommendations[indexPath.row];
    if(r.image && r.image.height > 0)
    {
        return (r.image.height / [UIScreen mainScreen].scale) + 20;
    }
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.numberOfLines = 4;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        cell.imageView.layer.borderWidth = 1.f;
        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    cell.imageView.image = nil;
    
    OBRecommendation *recommendation = _recommendationResponse.recommendations[indexPath.row];
    
    cell.textLabel.text = recommendation.content;
    NSString * prefix = recommendation.author?@"Author":@"Source";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@:  %@)",prefix,recommendation.author?:recommendation.source];
    
    if([self.imageCache objectForKey:recommendation.image.url.absoluteString])
    {
        cell.imageView.image = [self.imageCache objectForKey:recommendation.image.url.absoluteString];
        CGRect rect = CGRectMake(0, 0, recommendation.image.width, recommendation.image.height);
        rect.size.width /= [UIScreen mainScreen].scale;
        rect.size.height /= [UIScreen mainScreen].scale;
        
        rect.origin.x = cell.imageView.frame.origin.x;
        rect.origin.y = (cell.bounds.size.height - rect.size.height) / 2.f;
        cell.imageView.frame = rect;
        
    } else if(recommendation.image) {
        // Fetch the image and add to the cache
        __block NSIndexPath * imageIndexPath = [indexPath copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           
            OBRecommendation * r = self.recommendationResponse.recommendations[imageIndexPath.row];
            NSURL * imageURL = r.image.url;
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            if(imageData)
            {
                UIImage * image = [UIImage imageWithData:imageData];
                if(image)
                {
                    [self.imageCache setObject:image forKey:imageURL.absoluteString];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadRowsAtIndexPaths:@[imageIndexPath]
                                              withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }
            
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OBRecommendation * recommendation = _recommendationResponse.recommendations[indexPath.row];
//    [Outbrain registerClickForRecommendation:recommendation];
    NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:recommendation];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * message = [NSString stringWithFormat:@"Registering click event for url %@", url];
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Click" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [a show];
    });
}

@end
