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

@class SFHorizontalTableViewCell;
@class SFItemData;
@class SFHorizontalView;

@interface SFTableViewManager : NSObject

@property (nonatomic, weak) id<SFClickListener> clickListenerTarget;

- (id _Nonnull )initWithTableView:(UITableView * _Nonnull)tableView;

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath sfItemType:(SFItemType)sfItemType;

-(void) reloadUIData:(NSUInteger) currentCount indexPaths:(NSArray *)indexPaths sectionIndex:(NSInteger)sectionIndex;

- (CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem;

- (void) configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;
@end
