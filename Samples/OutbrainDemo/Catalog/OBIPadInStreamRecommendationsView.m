//
//  OBIPadInStreamRecommendationsView.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBIPadInStreamRecommendationsView.h"
#import "OBLabelExtensions.h"

@interface OBIPadInStreamRecommendationsView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * internalCollectionView;

@end
@interface SeparatorFlowLayout : UICollectionViewFlowLayout
@end

@implementation OBIPadInStreamRecommendationsView
@synthesize dataSource;
@synthesize delegate;
@synthesize internalCollectionView;

- (id)initWithCoder:(NSCoder *)aDecoder { self = [super initWithCoder:aDecoder]; if (self) { [self commonInit]; } return self;}
- (id)initWithFrame:(CGRect)frame { self = [super initWithFrame:frame]; if (self) { [self commonInit]; } return self;}

- (void)commonInit {
    // Create our collectionView here
    self.internalCollectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:[SeparatorFlowLayout new]];    
    self.internalCollectionView.scrollsToTop = NO;
    self.internalCollectionView.backgroundColor = self.backgroundColor;
    self.internalCollectionView.delegate = self;
    self.internalCollectionView.dataSource = self;
    self.internalCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.internalCollectionView registerClass:[OBIPadInStreamCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self addSubview:self.internalCollectionView];
    
    
    typeof(self) __weak __self = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [__self.internalCollectionView reloadData];
    }];
}

- (void)reloadData {
    [self.internalCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if (dataSource && [dataSource respondsToSelector:@selector(numberOfItems)]) {
        return [dataSource numberOfItems];
    }
    else {
        NSLog(@"You have to implement the numberOfItems function");
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [dataSource sizeForIndex:indexPath];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CellIdentifier";
    OBIPadInStreamCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell prepareForReuse];
    typeof(cell.imageView) __weak __iv = cell.imageView;
    [self fetchImageForURL:[NSURL URLWithString:[dataSource imageUrlForIndex:indexPath]] withCallback:^(UIImage *image) {
        __iv.image = image;
    }];
    
    NSString *title = [dataSource titleForIndex:indexPath];
    NSString *by = @" by ";
    NSString *source = [dataSource sourceForIndex:indexPath];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    if (title != nil) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:by]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:source]];
        
        
        [text addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]
                     range:NSMakeRange(0, [title length])];
        [text addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]
                     range:NSMakeRange([title length],[by length] + [source length])];
        
    }
    
    cell.titleLabel.attributedText = text;
    [cell.titleLabel sizeToFitFixedWidth:cell.titleLabel.frame.size.width];
    cell.categoryLabel.text = [dataSource categoryForIndex:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (delegate && [delegate respondsToSelector:@selector(itemClickedAtIndex:)]) {
        [delegate itemClickedAtIndex:indexPath];
    }
}

- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *))callback {
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

@end

@implementation UICollectionViewFlowLayout (Helpers)

- (BOOL)indexPathLastInSection:(NSIndexPath *)indexPath {
    NSInteger lastItem = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] -1;
    return  lastItem == indexPath.row;
}

- (BOOL)indexPathInLastLine:(NSIndexPath *)indexPath {
    NSInteger lastItemRow = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] -1;
    NSIndexPath *lastItem = [NSIndexPath indexPathForItem:lastItemRow inSection:indexPath.section];
    UICollectionViewLayoutAttributes *lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItem];
    UICollectionViewLayoutAttributes *thisItemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    return lastItemAttributes.frame.origin.y == thisItemAttributes.frame.origin.y;
}

- (BOOL)indexPathLastInLine:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *nextCellAttributes;
    @try {
        nextCellAttributes = [self layoutAttributesForItemAtIndexPath:nextIndexPath];
    }
    @catch(NSException *ex) {
        return YES;
    }
    return !(cellAttributes.frame.origin.y == nextCellAttributes.frame.origin.y);
}

@end

@interface SeparatorView : UICollectionReusableView

@end

@implementation SeparatorView

- (id)initWithCoder:(NSCoder *)aDecoder { self = [super initWithCoder:aDecoder]; if (self) { [self commonInit]; } return self;}
- (id)initWithFrame:(CGRect)frame { self = [super initWithFrame:frame]; if (self) { [self commonInit]; } return self;}
- (id)init { self = [super init]; if (self) { [self commonInit]; } return self;}

- (void)commonInit {
    float gray = 0.89803921568627f;
    self.backgroundColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1.0];
}

@end

@implementation SeparatorFlowLayout

- (void)prepareLayout {
    // Registers my decoration views.
    [self registerClass:[SeparatorView class] forDecorationViewOfKind:@"Vertical"];
    [self registerClass:[SeparatorView class] forDecorationViewOfKind:@"Horizontal"];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    // Prepare some variables.
    
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];

    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
    UICollectionViewLayoutAttributes *nextCellAttributes;
    @try {
        nextCellAttributes = [self layoutAttributesForItemAtIndexPath:nextIndexPath];
    }
    @catch(NSException *ex) {
        return layoutAttributes;
    }
    
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect baseFrame = cellAttributes.frame;
    CGRect nextFrame = nextCellAttributes.frame;
    
    CGFloat strokeWidth = 2;
    CGFloat spaceToNextItem = 0;
    if (nextFrame.origin.y == baseFrame.origin.y)
        spaceToNextItem = (nextFrame.origin.x - baseFrame.origin.x - baseFrame.size.width);
    
    if ([decorationViewKind isEqualToString:@"Vertical"]) {
        CGFloat padding = 0;
        
        // Positions the vertical line for this item.
        CGFloat x = baseFrame.origin.x + baseFrame.size.width + (spaceToNextItem - strokeWidth)/2;
        layoutAttributes.frame = CGRectMake(x,
                                            baseFrame.origin.y + padding,
                                            strokeWidth,
                                            baseFrame.size.height - padding*2);
    } else {
        if ([self indexPathInLastLine:indexPath] && [self indexPathLastInLine:indexPath]) {
            spaceToNextItem = 0;
        }
        // Positions the horizontal line for this item.
        layoutAttributes.frame = CGRectMake(baseFrame.origin.x,
                                            baseFrame.origin.y + baseFrame.size.height,
                                            baseFrame.size.width + spaceToNextItem,
                                            strokeWidth);
    }
    
    layoutAttributes.zIndex = -1;
    return layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *baseLayoutAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray * layoutAttributes = [baseLayoutAttributes mutableCopy];
    
    for (UICollectionViewLayoutAttributes *thisLayoutItem in baseLayoutAttributes) {
        if (thisLayoutItem.representedElementCategory == UICollectionElementCategoryCell) {
            UICollectionViewLayoutAttributes *newLayoutItem = [self layoutAttributesForDecorationViewOfKind:@"Vertical" atIndexPath:thisLayoutItem.indexPath];
            [layoutAttributes addObject:newLayoutItem];
        
        // Adds horizontal lines when the item isn't in the last line.
            UICollectionViewLayoutAttributes *newHorizontalLayoutItem = [self layoutAttributesForDecorationViewOfKind:@"Horizontal" atIndexPath:thisLayoutItem.indexPath];
            [layoutAttributes addObject:newHorizontalLayoutItem];
        }
    }
    
    return layoutAttributes;
}

@end
