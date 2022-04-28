//
//  OBErrorReporting.h
//  OutbrainSDK
//
//  Created by Oded Regev on 28/04/2022.
//  Copyright © 2022 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBErrorReporting : NSObject

+ (instancetype)sharedInstance;

- (void) reportErrorToServer:(NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
