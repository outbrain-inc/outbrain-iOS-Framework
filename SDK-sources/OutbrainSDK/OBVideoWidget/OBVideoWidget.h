//
//  OBVideoWidget.h
//  OutbrainSDK
//
//  Created by oded regev on 19/12/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>


@protocol OBVideoWidgetDelegate <NSObject>

-(void) userTappedOnRecommendation:(OBRecommendation *_Nonnull)rec;

-(void) userTappedOnAdChoicesIcon:(NSURL *_Nonnull)url;

-(void) userTappedOnVideoRec:(NSURL *_Nonnull)url;

-(void) userTappedOnOutbrainLabeling;

@end

@interface OBVideoWidget : NSObject

@property (nonatomic, strong, readonly) OBRequest * _Nonnull obRequest;

@property (nonatomic, weak) id<OBVideoWidgetDelegate> delegate;

- (id _Nonnull )initRequest:(OBRequest * _Nonnull)obRequest
              containerView:(UIView * _Nonnull)containerView;

-(void) start;

@end
