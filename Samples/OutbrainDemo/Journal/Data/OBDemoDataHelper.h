//
//  OBDemoDataHelper.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/27/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>


#define OBDemoURL   @"http://mobile-demo.outbrain.com/"

#define OBDemoWidgetID1     @"SDK_1"
#define OBDemoWidgetID2     @"SDK_2"
#define OBDemoWidgetID3     @"SDK_3"

#define IMAGE_SPACING @"\n\n\n\n\n"

@class Post;

/**
 *  This is our data helper class.
 *  Mostly so we can keep things nice and clean
 **/


@interface OBDemoDataHelper : NSObject <NSCoding>

/**
 *  Shared Instance.  Because we like it that way
 **/
+ (instancetype)defaultHelper;

/**
 *  Used for determining if we should show some response indicators
 **/
+ (BOOL)showsDebugIndicators;

@property (nonatomic, strong, readonly) NSMutableArray * posts;

/**
 *  Begin fetching the data for the sample app
 *  Since the app is CoreData we will only read data from CoreData, and the data helper will
 *  worry about fetching the data from the network.
 **/
- (void)updatePostsInViewController:(UIViewController *)vc withCallback:(void(^)(BOOL updated))callback;

/**
 *  Get and parse a single article
 **/
- (void)fetchPostForURL:(NSURL *)url withCallback:(void(^)(id postObject, NSError * error))callback;


/**
 *  Use to fetch an image
 **/
+ (void)fetchImageWithURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;

/**
 *  Common Methods for settings the text on the Post Page for both PostViewCell and TopBoxPostViewCell
 **/
+ (NSString *)_dateStringFromDate:(NSDate *)date;
+ (NSAttributedString *)_buildArticleAttributedStringWithPost:(Post *)post;

@end


@interface OBDemoDataHelper (Parsing)


/**
 *  Used to remove some unwanted content from the body/summary strings of a post
 **/
+ (NSString *)stringByStrippingHTMLOutbrainWidget:(NSString *)contentString;


/**
 *  Create a new post with the given server payload. 
 **/
+ (Post *)createPostWithPayload:(NSDictionary *)postPayload;

@end

@interface NSString (HTML_Extensions)
/**
 *  Strip down all HTML tags
 **/
- (NSString *)stringByStrippingHTML;
@end
