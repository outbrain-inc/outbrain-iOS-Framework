//
//  CustomUITextView.m
//  ViewabilityApp
//
//  Created by Oded Regev on 1/4/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRequest.h"

@interface OBLabel : UILabel;

@property (nonatomic) OBRequest * obRequest;

- (void) trackViewability;

@end
