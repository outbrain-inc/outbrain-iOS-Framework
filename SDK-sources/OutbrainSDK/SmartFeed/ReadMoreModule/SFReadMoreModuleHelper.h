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

- (void) collectionView:(UICollectionView * _Nonnull)collectionView handleShadowViewForCell:(UICollectionViewCell * _Nonnull)cell atIndexPath:(NSIndexPath *_Nonnull)indexPath;

- (void) tableView:(UITableView * _Nonnull)tableView handleShadowViewForCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath *_Nonnull)indexPath;

@end
