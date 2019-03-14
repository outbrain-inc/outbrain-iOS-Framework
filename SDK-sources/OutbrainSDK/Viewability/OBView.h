//
//  OBView.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 2/25/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRequest.h"

@interface OBView : UIView;

@property (nonatomic, strong) NSArray * positions;
@property (nonatomic, strong) NSString * requestId;
@property (nonatomic, strong) NSDate * smartFeedInitializationTime;


- (void) trackViewability;

@end
