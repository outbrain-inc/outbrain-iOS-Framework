//
//  OBTableViewHeader.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/28/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBTableViewHeaderDelegate<NSObject>
- (void)brandingDidClick;
@end

@interface OBTableViewHeader : UIView 
    
@property (nonatomic, weak) id<OBTableViewHeaderDelegate> delegate;
@property (nonatomic, assign) float ameliaHeaderHeight;
@end
