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

@property (nonatomic, strong, readonly) NSString * _Nullable url;
@property (nonatomic, strong, readonly) NSString * _Nullable widgetId;

@property (nonatomic, weak) id<OBVideoWidgetDelegate> delegate;

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId

@end
