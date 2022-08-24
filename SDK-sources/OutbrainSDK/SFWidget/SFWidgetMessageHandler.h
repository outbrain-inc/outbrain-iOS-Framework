//
//  SFWidgetMessageHandler.h
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SFMessageHandlerDelegate

- (void) didHeightChanged:(NSInteger)height;
- (void) didClickOnRec:(NSString *)url;
- (void) didClickOnOrganicRec:(NSString *)url orgUrl:(NSString *)orgUrl;
- (void) widgetRendered;

@end


@interface SFWidgetMessageHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<SFMessageHandlerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
