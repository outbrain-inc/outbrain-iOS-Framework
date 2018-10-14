//
//  SFScriptMessageHandler.h
//  OutbrainSDK
//
//  Created by oded regev on 14/10/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFUtils.h"

@import WebKit;

@interface SFScriptMessageHandler : NSObject <WKScriptMessageHandler>

- (id)initWithSFVideoCell:(id<SFVideoCellType>)videoCell;

@end
