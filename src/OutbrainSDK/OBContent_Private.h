//
//  OBContent_Private.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <OutbrainSDK/OutbrainSDK.h>

@interface OBContent ()
/**
 *  Helper creator
 **/
+ (instancetype)contentWithPayload:(NSDictionary *)payload;


/**
 *  Required fields for the object to be non-nil
 **/
+ (NSArray *)requiredKeys;

/**
 *  Return property => payload_key mappings
 **/
+ (NSDictionary *)propertiesMap;

/**
 *  If one a key in `propertiesMap` maps to a dictionary
 *  in the response.  Then we will call [OBContent contentWithPayload:] with this class
 **/
+ (Class)propertyClassForKey:(NSString *)key;

/**
 *  This gets called for any value that has a custom class.
 *  By default handles OBContent subclasses, NSURL, and NSDate
 **/
+ (id)convertedValue:(id)value withClass:(Class)class;



/**
 *  Some Helpers
 **/

- (id)originalValueForKeyPath:(NSString *)keyPath;
@end
