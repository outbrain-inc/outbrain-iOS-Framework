//
//  SFWeeklyHighlightsItemCell.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 7/27/20.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SFWeeklyHighlightsSingleRecView.h>

@interface SFWeeklyHighlightsItemCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *dateView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet SFWeeklyHighlightsSingleRecView *recOneView;
@property (nonatomic, weak) IBOutlet SFWeeklyHighlightsSingleRecView *recTwoView;
@property (nonatomic, weak) IBOutlet SFWeeklyHighlightsSingleRecView *recThreeView;

@end
