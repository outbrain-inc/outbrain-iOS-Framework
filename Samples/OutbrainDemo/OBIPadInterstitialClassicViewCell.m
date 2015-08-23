//
//  OBIPadInterstitialClassicViewCell.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 7/10/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBIPadInterstitialClassicViewCell.h"
#import "OBLabelWithPadding.h"
#import "OBLabelExtensions.h"

//VIEW PROPERTIES
#define IMAGE_HEIGHT 150.0f
#define IMAGE_VIEW_BOTTOM_PADDING 5.0f
#define SOURCE_LABEL_BOTTOM 5.0f
#define ARC4RANDOM_MAX      0x100000000
#define FTW_LABEL_WIDTH 150.0f
#define FTW_LABEL_HEIGHT 25.0f
#define FTW_LABEL_TOP_BOTTOM_PADDING 10.0f
#define FTW_LABEL_LEFT_PADDING 5.0f
#define CELL_LABELS_SIDE_PADDING 10.0f
#define CELL_HORIZONTAL_SPACING 5.0f
#define CELL_VERTICAL_SPACING 5.0f

@interface OBIPadInterstitialClassicViewCell ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) OBLabelWithPadding *fromTheWebLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation OBIPadInterstitialClassicViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.bgView];
    
    self.iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, IMAGE_HEIGHT)];
    self.iv.backgroundColor = [UIColor lightGrayColor];
    self.iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.iv.contentMode = UIViewContentModeScaleAspectFill;
    self.iv.clipsToBounds = YES;
    [self.contentView addSubview:self.iv];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.titleLabel];
    
    self.sourceLabel = [UILabel new];
    self.sourceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sourceLabel.font = [UIFont systemFontOfSize:12.f];
    self.sourceLabel.textColor = [UIColor orangeColor];
    self.sourceLabel.numberOfLines = 1;
    self.sourceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.sourceLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.sourceLabel];

    self.fromTheWebLabel = [[OBLabelWithPadding alloc] init];
    float darknessFactor = -0.15f;
    double r = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;
    double g = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;
    double b = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;
    
    self.fromTheWebLabel.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    self.fromTheWebLabel.edgeInsets = UIEdgeInsetsMake(FTW_LABEL_TOP_BOTTOM_PADDING, FTW_LABEL_LEFT_PADDING, FTW_LABEL_TOP_BOTTOM_PADDING, 0);
    self.fromTheWebLabel.numberOfLines = 1;
    self.fromTheWebLabel.textColor = [UIColor whiteColor];
    self.fromTheWebLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    self.fromTheWebLabel.frame = CGRectMake(CGRectGetMaxX(self.iv.frame) - FTW_LABEL_WIDTH, CGRectGetMaxY(self.iv.frame) - FTW_LABEL_HEIGHT/2, FTW_LABEL_WIDTH, FTW_LABEL_HEIGHT);
    self.fromTheWebLabel.text = @"FROM THE WEB";
    self.fromTheWebLabel.hidden = YES;
    self.fromTheWebLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:self.fromTheWebLabel];
    
    UIView * v = [[UIView alloc] initWithFrame:self.bounds];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f];
    self.selectedBackgroundView = v;
}

- (void)setRecommendation:(OBRecommendation *)rec {
    self.titleLabel.text = rec.content;
    [self.titleLabel sizeToFitFixedWidth:self.frame.size.width - 2*CELL_LABELS_SIDE_PADDING];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.numberOfLines = 2;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(CELL_LABELS_SIDE_PADDING, CGRectGetMaxY(self.iv.frame) + IMAGE_VIEW_BOTTOM_PADDING + FTW_LABEL_HEIGHT / 2, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);

    self.sourceLabel.text = [NSString stringWithFormat:@"(%@)",rec.source];
    [self.sourceLabel sizeToFitFixedWidth:self.titleLabel.frame.size.width];
    self.sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.sourceLabel.numberOfLines = 2;
    [self.sourceLabel sizeToFit];
    self.sourceLabel.frame = CGRectMake(CELL_LABELS_SIDE_PADDING, CGRectGetMaxY(self.titleLabel.frame), self.sourceLabel.frame.size.width, self.sourceLabel.frame.size.height);

    if (![rec isPaidLink]) {
        UIColor *topColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0];
        UIColor *bottomColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2f];
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bgView.bounds;
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];

        [self.bgView.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.fromTheWebLabel.hidden = ![rec isPaidLink];

    typeof(self.iv) __weak __iv = self.iv;
    [self fetchImageForURL:rec.image.url withCallback:^(UIImage *image) {
        [__iv setImage:image];
    }];

}

+ (CGSize)sizeForRec:(OBRecommendation *)rec collectionViewWidth:(CGFloat)width {
    CGSize cellSize;
    cellSize.width = (width - 6*CELL_HORIZONTAL_SPACING) / 3;
    UILabel *titleLabel = [self makeTitleLabelWithText:rec.content toFit:cellSize.width - 2*CELL_LABELS_SIDE_PADDING];
    UILabel *sourceLabel = [self makeSourceLabelWithText:[NSString stringWithFormat:@"(%@)",rec.source] toFit:cellSize.width - 2*CELL_LABELS_SIDE_PADDING];
    cellSize.height += IMAGE_HEIGHT;
    cellSize.height += IMAGE_VIEW_BOTTOM_PADDING;
    cellSize.height += titleLabel.frame.size.height;
    cellSize.height += sourceLabel.frame.size.height;
    cellSize.height += SOURCE_LABEL_BOTTOM;
    cellSize.height += FTW_LABEL_HEIGHT / 2;
    return cellSize;
}

+ (UILabel *)makeTitleLabelWithText:(NSString *)text toFit:(CGFloat)width {
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.text = text;
    [titleLabel sizeToFitFixedWidth:width];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.numberOfLines = 2;
    [titleLabel sizeToFit];
    
    titleLabel.frame = CGRectMake(CELL_LABELS_SIDE_PADDING, IMAGE_HEIGHT + IMAGE_VIEW_BOTTOM_PADDING + FTW_LABEL_HEIGHT / 2, titleLabel.frame.size.width, titleLabel.frame.size.height);

    return titleLabel;
}

+ (UILabel *)makeSourceLabelWithText:(NSString *)text toFit:(CGFloat)width {
    UILabel *sourceLabel = [UILabel new];
    sourceLabel.font = [UIFont systemFontOfSize:12.f];
    sourceLabel.text = text;
    sourceLabel.textColor = [UIColor orangeColor];
    sourceLabel.numberOfLines = 1;
    sourceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    sourceLabel.backgroundColor = [UIColor clearColor];
    [sourceLabel sizeToFitFixedWidth:width];
    return sourceLabel;
}

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

- (void)prepareForReuse {
    [super prepareForReuse];
    if ([[self.bgView.layer.sublayers objectAtIndex:0] isEqual:self.gradientLayer]) {
        [self.gradientLayer removeFromSuperlayer];
    }
}

@end
