//
//  OBDisclosure.h
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBContent.h"

@interface OBDisclosure : OBContent 

/** @brief The image URL */
@property (nonatomic, copy) NSString *imageUrl;

/** @brief The URL to open onClick */
@property (nonatomic, copy) NSURL *clickUrl;

@end
