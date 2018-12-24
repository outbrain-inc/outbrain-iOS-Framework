//
//  OBVideoWidget.m
//  OutbrainSDK
//
//  Created by oded regev on 19/12/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "OBVideoWidget.h"
#import "SFUtils.h"
#import "SFVideoCollectionViewCell.h"

@interface OBVideoWidget()

@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * widgetId;
@property (nonatomic, weak) UIView * containerView;


@end

@implementation OBVideoWidget

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
              containerView:(UIView * _Nonnull)containerView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        self.url = url;
        self.widgetId = widgetId;
        self.containerView = containerView;
    }
    return self;
}

-(void) start {
    [self loadUIInContainerView];
}

-(void) loadUIInContainerView {
    NSBundle *bundle = [NSBundle bundleForClass:[OBVideoWidget class]];
    SFVideoCollectionViewCell *videoCell = (SFVideoCollectionViewCell *)[[bundle loadNibNamed:@"SFSingleVideoWithTitleCollectionViewCell" owner:self options:nil] objectAtIndex:0];
    
    NSLog(@"rootView: %@", videoCell);
    [self.containerView addSubview:videoCell];
    [SFUtils addConstraintsToFillParent:videoCell];
}

@end
