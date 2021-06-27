//
//  SFWidget.h
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "SFWidgetTableCell.h"
#import "SFWidgetCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SFWidgetDelegate

- (void) didChangeHeight;

- (void) onRecClick:(NSURL * _Nonnull) url;

@optional

- (void) onOrganicRecClick:(NSURL * _Nonnull) url;

@end


@interface SFWidget : UIView

-(void) configureWithDelegate:(id<SFWidgetDelegate>)delegate url:(NSString *)url widgetId:(NSString *)widgetId installationKey:(NSString *)installationKey userId:(NSString *)userId;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (CGFloat) getCurrentHeight;

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

-(void) willDisplaySFWidgetTableCell:(SFWidgetTableCell *)cell;

-(void) willDisplaySFWidgetCollectionCell:(SFWidgetCollectionCell *)cell;

@end

NS_ASSUME_NONNULL_END
