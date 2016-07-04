//
//  CustomUITextView.m
//  ViewabilityApp
//
//  Created by Oded Regev on 1/4/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBLabel : UILabel;

@property (nonatomic, copy) NSString * widgetId;
@property (nonatomic, copy) NSString * url;

- (void) trackViewability;

@end
