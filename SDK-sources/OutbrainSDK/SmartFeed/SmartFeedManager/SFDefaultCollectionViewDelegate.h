//
//  SFDefaultCollectionViewDelegate.h
//  OutbrainSDK
//
//  Created by oded regev on 29/07/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SmartFeedManager.h"

@interface SFDefaultCollectionViewDelegate : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak, readonly) SmartFeedManager * _Nullable smartfeedManager;

- (id _Nonnull )initWithSmartfeedManager:(SmartFeedManager * _Nonnull)smartfeedManager;

@end

