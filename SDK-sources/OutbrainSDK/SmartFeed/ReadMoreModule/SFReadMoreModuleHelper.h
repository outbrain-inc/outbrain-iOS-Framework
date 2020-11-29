//
//  SFReadMoreModuleHelper.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 29/11/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFReadMoreModuleHelper : NSObject

@property (nonatomic) BOOL shouldExpandCollapsableSectionCells;
@property (nonatomic) BOOL shouldCollapseReadMoreCell;
@property (nonatomic, assign) NSInteger readMoreCollapsableSection;

- (CGFloat) heightForReadMoreItem;

- (NSInteger) numberOfItemsInCollapsableSection: (NSInteger)section collapsableItemCount: (NSInteger)collapsableItemCount;

- (void) readMoreButonClickedOnTableView:(UITableView * _Nonnull)tableView;

- (void) readMoreButonClickedOnCollectionView:(UICollectionView * _Nonnull)collectionView;

- (void) addShadowViewForCell:(UIView * _Nonnull)cell;

@end
