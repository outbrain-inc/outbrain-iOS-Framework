//
//  SFTableViewManager.h
//  OutbrainSDK
//
//  Created by oded regev on 09/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartFeedManager.h"
#import "SFUtils.h"
#import "SFTableViewCell.h"

@import WebKit;

@class SFHorizontalTableViewCell;
@class SFItemData;
@class SFHorizontalView;


@interface SFTableViewManager : NSObject

@property (nonatomic, weak) id<SFPrivateEventListener> _Nullable eventListenerTarget;
@property (nonatomic, weak) id<WKUIDelegate> _Nullable wkWebviewDelegate;
@property (nonatomic, weak, readonly) UITableView * _Nullable tableView;
@property (nonatomic) BOOL displaySourceOnOrganicRec;
@property (nonatomic) BOOL disableCellShadows;

- (id _Nonnull )initWithTableView:(UITableView * _Nonnull)tableView;

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView headerCellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath isRTL:(BOOL)isRTL;

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView readMoreCellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInCollapsableSection: (NSInteger)section collapsableItemCount: (NSInteger)collapsableItemCount;

- (void) configureReadMoreTableViewCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath sfItemType:(SFItemType)sfItemType;

- (CGFloat) heightForReadMoreRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (CGFloat) heightForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath withSFItem:(SFItemData * _Nonnull)sfItem;

- (void) configureSingleTableViewCell:(SFTableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath withSFItem:(SFItemData * _Nonnull)sfItem;

- (void) configureVideoCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath withSFItem:(SFItemData * _Nonnull)sfItem;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

@end
