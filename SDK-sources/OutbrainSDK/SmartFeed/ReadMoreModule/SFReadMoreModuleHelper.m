//
//  SFReadMoreModuleHelper.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 29/11/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFReadMoreModuleHelper.h"
#import "SFUtils.h"

@interface SFReadMoreModuleHelper()

@property (nonatomic, weak) UIView * _Nullable readMoreShadowView;

@end

@implementation SFReadMoreModuleHelper

- (CGFloat) heightForReadMoreItem {
    return self.shouldCollapseReadMoreCell ? 0 : 35.0;
}

- (NSInteger) numberOfItemsInCollapsableSection: (NSInteger)section collapsableItemCount: (NSInteger)collapsableItemCount {
    self.readMoreCollapsableSection = section;
    return self.shouldExpandCollapsableSectionCells ? collapsableItemCount : 0;
}

// We are adding the shadow to the last cell in the section before the collapsible section.
// readMoreCollapsableSection : collapsible section
// readMoreCollapsableSection - 1 : section before the collapsible section
- (void) collectionView:(UICollectionView *)collectionView handleShadowViewForCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.readMoreCollapsableSection - 1) {
        NSInteger numberOfItemsInSection = [collectionView numberOfItemsInSection:indexPath.section];
        if ((numberOfItemsInSection - 1) == indexPath.item) { // is last item in section
            [self addShadowViewForCell:cell.contentView];
            return;
        }
    } else { // make sure we remove the shadow view for reuse cells
        [self removeShadowViewIfNeededForCell:cell.contentView];
    }
}

// We are adding the shadow to the last cell in the section before the collapsible section.
// readMoreCollapsableSection : collapsible section
// readMoreCollapsableSection - 1 : section before the collapsible section
- (void) tableView:(UITableView *)tableView handleShadowViewForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.readMoreCollapsableSection - 1) {
        NSInteger numberOfItemsInSection = [tableView numberOfRowsInSection:indexPath.section];
        if ((numberOfItemsInSection - 1) == indexPath.item) { // is last item in section
            [self addShadowViewForCell:cell.contentView];
            return;
        }
    } else { // make sure we remove the shadow view for reuse cells
        [self removeShadowViewIfNeededForCell:cell.contentView];
    }
}

- (void) removeShadowViewIfNeededForCell:(UIView *)cell {
    if ([cell.subviews containsObject: self.readMoreShadowView]) {
        [self.readMoreShadowView removeFromSuperview];
    }
}

- (void) addShadowViewForCell:(UIView *)cell {
    if ([cell.subviews containsObject: self.readMoreShadowView]) {
        if (self.shouldCollapseReadMoreCell) {
            [self.readMoreShadowView removeFromSuperview];
        }
        return;
    }
    if (self.shouldCollapseReadMoreCell) {
        return;
    }
    UIView * shadowView = [[UIView alloc] init];
    [cell addSubview:shadowView];
    
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[shadowView leadingAnchor] constraintEqualToAnchor:[cell leadingAnchor] constant:0].active = YES;
    [[shadowView trailingAnchor] constraintEqualToAnchor:[cell trailingAnchor] constant:0].active = YES;
    [[shadowView heightAnchor] constraintEqualToConstant:100].active = YES;
    [[shadowView bottomAnchor] constraintEqualToAnchor:[cell bottomAnchor] constant:0].active = YES;
    
    [shadowView layoutIfNeeded];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = shadowView.bounds;
    bool isDarkMode = [[SFUtils sharedInstance] darkMode];
    if (isDarkMode) {
        gradient.colors = @[(id)[UIColor colorWithWhite:0 alpha:0].CGColor, (id) [UIColor blackColor].CGColor];
    } else {
        gradient.colors = @[(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id) [UIColor whiteColor].CGColor];
    }
    
    gradient.locations = @[@0.0, @1.0];

    [shadowView.layer insertSublayer:gradient atIndex:0];
    
    [shadowView setNeedsLayout];
    
    self.readMoreShadowView = shadowView;
}

- (void) readMoreButonClickedOnCollectionView:(UICollectionView * _Nonnull)collectionView {
    NSLog(@"readMoreButonClicked");

    self.shouldExpandCollapsableSectionCells = true;

    [UIView animateWithDuration:0.5 animations:^{
        self.readMoreShadowView.alpha = 0;
    }];

    [UIView animateWithDuration:1 delay:0 options: UIViewAnimationOptionTransitionNone animations:^{
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:self.readMoreCollapsableSection];
        [collectionView reloadSections:indexSet];
        
    } completion:^(BOOL finished) {
        [ collectionView performBatchUpdates:^{
            self.shouldCollapseReadMoreCell = true;
        } completion:nil];
    }];
}

- (void) readMoreButonClickedOnTableView:(UITableView * _Nonnull)tableView {
    NSLog(@"readMoreButonClicked");
    
    self.shouldExpandCollapsableSectionCells = true;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.readMoreShadowView.alpha = 0;
    }];
    
    [UIView animateWithDuration:1 delay:0 options: UIViewAnimationOptionTransitionNone animations:^{
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:self.readMoreCollapsableSection];
        [tableView reloadSections: indexSet withRowAnimation:UITableViewRowAnimationFade];
        
    } completion:^(BOOL finished) {
        self.shouldCollapseReadMoreCell = true;
        [tableView beginUpdates];
        [tableView endUpdates];
    }];
}

@end
