//
//  OutbrainSDK.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/9/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/NSArray.h>
#import <OutbrainSDK/OBProtocols.h>


@class OBRequest;
@class OBResponse;
@class OBRecommendation;

/**
 *  This is the main outbrain class.  Enjoy!
 **/

// The current version of the sdk
extern NSString * const OB_SDK_VERSION;

@interface Outbrain : NSObject

/** @section Initialize **/

/**
 *  Discussion:
 *      You must call this before using the sdk for anything else
 *  Params:
 *      @pathToFile - The path to the configuration file.
 *                    The path can be absolute, or just the name (if it's in the main bundle).
 *                    Must be a plist or a valid json file.  (extension defaults to .json if not provided)
 *      e.g:  
 *          /Library/Applications/some/long/path/OBConfig.(plist or json)       <-- VALID
 *          OBConfig.(plist or json)                                            <-- VALID (if in your main bundle)
 *          OBConfig                                                            <-- VALID (if OBConfig.json is in your main bundle)
**/
+ (void)initializeOutbrainWithConfigFile:(NSString *)pathToFile;


/** @section Fetching **/

/**
 *  Discussion:
 *      The below methods will fetch recommendations for the given `OBRequest` object.
 **/
+ (void)fetchRecommendationsForRequest:(OBRequest *)request
                          withCallback:(OBResponseCompletionHandler)handler;

+ (void)fetchRecommendationsForRequest:(OBRequest *)request
                       withDelegate:(__weak id<OBResponseDelegate>)delegate;


/** @section Click Handling **/

/**
 *  Discussion:
 *      Use this to get the contentURL for the given `OBRecommendation` object.
 *      You will use this url to either display a `UIWebView`, or if it is nagive content you can
 *      pull the #mobile_id from the url
 *
 *  Params:
 *      @recommendation - The recommendation object to get the contentURL for
 *
 *  Examples: 
 *      http://google.com/blog/some_page.html - This type of url you will probably just use UIWebView
 *      http://google.com/blog/some_page.html#mobile_id=12345&source=http://www.myappsource.com
 *
 *  @note - If the user is clicking on recommended content, and you're pushing to another
 *          view of with related content.  Then you should call this before you make the other recommended
 *          content request
 **/
+ (NSURL *)getOriginalContentURLAndRegisterClickForRecommendation:(OBRecommendation *)recommendation;

/**
 *  Discussion:
 *      Use this while developing in order to indicate this request should bypass all Outbrain's regular
 *      mechanisms, such as reporting and billing.
 *
 *
 *  Params:
 *      @testMode - a flag which indicates whether the request is in testing mode or not
 *
 **/

+ (void)setTestMode:(BOOL)testMode;

@end