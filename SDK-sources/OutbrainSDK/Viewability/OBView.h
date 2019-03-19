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

@property (nonatomic, strong) NSString * key;

- (void) trackViewability;

@end
