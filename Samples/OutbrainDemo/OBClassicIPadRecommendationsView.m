//
//  OBClassicIpadRecommendationsViewController.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBClassicIPadRecommendationsView.h"
#import <OutbrainSDK/OBRecommendationResponse.h>
#import "OBLabelExtensions.h"
#import "OBLabelWithPadding.h"

#define LEFT_RIGHT_CELL_PADDING 10.0f
#define TOP_CELL_PADDING 5.0f
#define LEFT_RIGHT_CELL_MARGIN 25.0f
#define HEIGHT_BEHIND_HEADER 30.0f
#define IMAGE_VIEW_WIDTH 100.0f
#define IMAGE_VIEW_HEIGHT 80.0f
#define VERTICAL_CELL_SPACE 5.0f
#define HORIZONTAL_CELL_SPACE 10.0f

#define FROM_THE_WEB_LEFT_FAKE_MARGIN 15.0f
#define FROM_THE_WEB_BOTTOM_FAKE_MARGIN 20.0f
#define FROM_THE_WEB_HEIGHT 40.0f

#define TEXT_VIEW_HEIGHT 300

@interface OBClassicIPadRecommendationsView ()

/**
 *  Discussion:
 *      Use UICollecitonView to layout our recommendations
 **/
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) OBTableViewHeader *fromTheWebHeader;
@property (nonatomic, strong) UIView *recsBackground;

@end

// Define our reuse identifier
static NSString * RecommendationCellID = @"RecommendationCellID";
static NSString * BrandingHeaderID = @"BrandingHeaderID";


// Our Cell class for holding the views for us
@interface OBIPadRecommendationCell : UIView
@property (nonatomic, strong) UIView * whiteBackground;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * sourceLabel;

@property (nonatomic, assign, getter = isInitialized) BOOL initialized;

- (void)setupSubviews;

@end

@interface OBIPadClassicRecommendationsMainCell : UIView
@property (nonatomic, strong) OBLabelWithPadding * titleLabel;
@end

@implementation OBIPadClassicRecommendationsMainCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[OBLabelWithPadding alloc] initWithFrame:frame];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.edgeInsets = UIEdgeInsetsMake(10,10,10,10);
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.   Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.   Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.   Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.   Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.   Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
        [self addSubview:self.titleLabel];
    }
    return self;
}

@end


@implementation OBIPadRecommendationCell
// Setup our (images,labels,colors, etc...) if necessary
- (void)setupSubviews {
    self.whiteBackground = [UIView new];
    self.whiteBackground.layer.masksToBounds = NO;
    self.whiteBackground.layer.shadowOffset = CGSizeMake(0, 2);
    self.whiteBackground.layer.shadowOpacity = 0.5;
    self.whiteBackground.backgroundColor = [UIColor whiteColor];
    self.whiteBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.whiteBackground];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_RIGHT_CELL_PADDING, TOP_CELL_PADDING, IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:self.titleLabel];
    
    self.sourceLabel = [UILabel new];
    self.sourceLabel.backgroundColor = [UIColor clearColor];
    self.sourceLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.sourceLabel.font = [UIFont systemFontOfSize:12];
    self.sourceLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.sourceLabel];
    
    self.initialized = YES;
}
@end



/**
 *  Discussion:
 *      This is our actual recommendationsView implementation
 **/
@implementation OBClassicIPadRecommendationsView

 #pragma mark - Initialize

- (void)commonInit
{
    //Create our scroll view here
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.scrollView];
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Setters

- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    // No need to do anything if the recommendation responses are equal
    if([recommendationResponse isEqual:_recommendationResponse]) return;
    
    _recommendationResponse = recommendationResponse;

    [self assignCells];
}

- (void)assignCells {
    int y = 0;
    int i = 0;
    OBIPadClassicRecommendationsMainCell * mainCell = [[OBIPadClassicRecommendationsMainCell alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, TEXT_VIEW_HEIGHT)];
    [self.scrollView addSubview:mainCell];
    y += TEXT_VIEW_HEIGHT;

    for (OBRecommendation *recommendation in self.recommendationResponse.recommendations) {
        if (i == 0) {
            if ([self.recommendationResponse.recommendations count] > 0) {
                // Create the header
                self.fromTheWebHeader = [[OBTableViewHeader alloc] initWithFrame:CGRectMake(LEFT_RIGHT_CELL_MARGIN - FROM_THE_WEB_LEFT_FAKE_MARGIN, y , self.scrollView.frame.size.width - LEFT_RIGHT_CELL_MARGIN, FROM_THE_WEB_HEIGHT)];
                self.fromTheWebHeader.ameliaHeaderHeight = 5.0f;
                self.fromTheWebHeader.delegate = self;
                [self.scrollView addSubview:self.fromTheWebHeader];
                y += FROM_THE_WEB_HEIGHT - FROM_THE_WEB_BOTTOM_FAKE_MARGIN;
                
                // Create the gray background
                self.recsBackground = [[UIView alloc] initWithFrame:CGRectMake(LEFT_RIGHT_CELL_MARGIN, y,  self.scrollView.frame.size.width - 2*LEFT_RIGHT_CELL_MARGIN, 0)];
                self.recsBackground.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.000];
                [self.scrollView addSubview:self.recsBackground];
                y += 10.0f; //margin between recs background and beginning of recs
            }
        }
        CGSize itemSize = CGSizeMake((self.scrollView.frame.size.width - 3*HORIZONTAL_CELL_SPACE - 2* LEFT_RIGHT_CELL_MARGIN) / 2,  IMAGE_VIEW_HEIGHT + VERTICAL_CELL_SPACE);
        int x = LEFT_RIGHT_CELL_MARGIN + HORIZONTAL_CELL_SPACE;
        if (i % 2 == 1) {
            x = itemSize.width + 2*HORIZONTAL_CELL_SPACE + LEFT_RIGHT_CELL_MARGIN;
        }
        
        OBIPadRecommendationCell * cell = [[OBIPadRecommendationCell alloc] initWithFrame:CGRectMake(x,y, itemSize.width, itemSize.height)];
        cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell setupSubviews];
        
        if (i % 2 == 1 || i == [self.recommendationResponse.recommendations count] - 1) {
            y += itemSize.height;
            y += VERTICAL_CELL_SPACE;
        }
        
        cell.titleLabel.text = recommendation.content;
        cell.sourceLabel.text = [NSString stringWithFormat:@"(%@)",recommendation.source];
        
        typeof(cell) __weak __cell = cell;
        [self fetchImageForURL:recommendation.image.url withCallback:^(UIImage *image) {
            [__cell.imageView setImage:image];
        }];
        
        CGFloat xOff = CGRectGetMaxX(cell.imageView.frame) + 5.f;
        
        cell.imageView.frame = CGRectMake(0, 0, cell.imageView.frame.size.width, cell.frame.size.height);
        
        cell.whiteBackground.frame = CGRectMake(0, 0, cell.frame.size.width, cell.imageView.frame.size.height);
        
        cell.titleLabel.frame = CGRectMake(xOff + 5.f, 0, cell.whiteBackground.frame.size.width - 5.0f, cell.bounds.size.height);
        int fixedWidth = cell.whiteBackground.frame.size.width - IMAGE_VIEW_WIDTH - 10.0f;

        [cell.titleLabel sizeToFitFixedWidth:fixedWidth];
        cell.titleLabel.center = CGPointMake(xOff + CGRectGetMidX(cell.titleLabel.bounds) - 5.0f, CGRectGetMidY(cell.titleLabel.bounds));
        
        [cell.sourceLabel sizeToFitFixedWidth:fixedWidth];
        cell.sourceLabel.center = CGPointMake(xOff + CGRectGetMidX(cell.sourceLabel.bounds) - 5.0f, CGRectGetMidY(cell.sourceLabel.bounds) + CGRectGetMaxY(cell.titleLabel.frame));
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [cell addGestureRecognizer:tapRecognizer];
        cell.tag = i;
        // This ensures that our selectedView will show on top of our content.
        [self.scrollView addSubview:cell];
        [self.scrollView bringSubviewToFront:self.fromTheWebHeader];
        i++;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, y);
    
    CGRect bgFrame = self.recsBackground.frame;
    bgFrame.size.height = y - FROM_THE_WEB_HEIGHT + FROM_THE_WEB_BOTTOM_FAKE_MARGIN - TEXT_VIEW_HEIGHT;
    self.recsBackground.frame = bgFrame;
}

- (void)cellTapped:(id)obj {
    NSInteger i = ([(UITapGestureRecognizer *)obj view]).tag;
    OBRecommendation *recommendation = self.recommendationResponse.recommendations[i];
    if (self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetView:tappedRecommendation:)]) {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
}

// Simple image fetching with GCD
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
            }
        }
    });
}


#pragma mark - Selection

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    // Selected an outbrain recommendation
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
    if(self.widgetDelegate)
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
}

- (void)brandingDidClick {
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
