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

@protocol SFWidgetDelegate <NSObject>

- (void) didChangeHeight;

- (void) onRecClick:(NSURL * _Nonnull) url;

@optional

- (void) onOrganicRecClick:(NSURL * _Nonnull) url;

@end

extern NSString * _Nonnull const SFWIDGET_T_PARAM_NOTIFICATION;


@interface SFWidget : UIView

-(void) configureWithDelegate:(id<SFWidgetDelegate> _Nonnull)delegate url:(NSString * _Nonnull)url widgetId:(NSString * _Nonnull)widgetId installationKey:(NSString * _Nonnull)installationKey userId:(NSString * _Nullable)userId;

-(void) configureWithDelegate:(id<SFWidgetDelegate> _Nonnull)delegate url:(NSString * _Nonnull)url widgetId:(NSString * _Nonnull)widgetId widgetIndex:(NSInteger)widgetIndex installationKey:(NSString * _Nonnull)installationKey userId:(NSString * _Nullable)userId;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (CGFloat) getCurrentHeight;

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

-(void) willDisplaySFWidgetTableCell:(SFWidgetTableCell *)cell;

-(void) willDisplaySFWidgetCollectionCell:(SFWidgetCollectionCell *)cell;

@end

NS_ASSUME_NONNULL_END
