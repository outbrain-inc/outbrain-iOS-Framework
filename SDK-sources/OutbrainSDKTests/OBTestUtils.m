//
//  OBTestUtils.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/23/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBTestUtils.h"

@implementation OBTestUtils

+ (NSDictionary *)JSONFromFile:(NSString *)fileName
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self dictionaryFromData: data];
}

+ (NSDictionary *) dictionaryFromData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *dict = nil;
    
    if(data != nil)
    {
        dict = [NSJSONSerialization JSONObjectWithData:data options:(0) error:&error];
    }
    else
    {
        return nil;
    }
    
    return dict;
}

@end
