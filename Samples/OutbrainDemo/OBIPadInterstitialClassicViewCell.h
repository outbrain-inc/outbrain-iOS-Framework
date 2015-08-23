//
//  OBIPadInterstitialClassicViewCell.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 7/10/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

@interface OBIPadInterstitialClassicViewCell : UICollectionViewCell

- (void)setRecommendation:(OBRecommendation *)rec;
+ (CGSize)sizeForRec:(OBRecommendation *)rec collectionViewWidth:(CGFloat) width;
@end
