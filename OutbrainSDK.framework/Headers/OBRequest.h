//
//  OBWidget.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  This class represents a single widget as it pertains to outbrain.  
 *
 *  A widget is a user-facing group of outbrain recommendations.
 **/


@interface OBRequest : NSObject

/**
 *  Discussion: (Required)
 *      This is the url that you wish to fetch recommendations for.
 *  Defaults: nil
 **/
@property (nonatomic, copy) NSString * url;

/**
 *  Discussion: (Required)
 *      The widgetID that you would like to register under with outbrain
 *  Defaults: nil
 **/
@property (nonatomic, copy) NSString * widgetId;

/**
 *  Discussion:
 *      If there are multiple widgets with the same `widgetID` on the same page, then this represents
 *      the index of each widget on the page.  Start at 0 and move up by 1
 *  Defaults: 0
 *
 *  @note: This should only be set if there is more than 1 of the same `widgetID` on the same page.
 **/
@property (nonatomic, assign) NSInteger widgetIndex;


/**
 *  Discussion: (Optional)
 *      This determines if the request is for a homepage. 
 *      (i.e.  This request for recommendations isn't tied to any one piece of content).
 **/
@property (nonatomic, assign, getter = isHomepageRequest) BOOL homePageRequest;



/**
 *  Discussion:
 *      Convenience creator for defining an `OBRequest` object
 *
 *  Params:
 *      @url - The link that you wish to request recommendations for
 *      @widgetId - The widgetID (given by outbrain) to request recommendations for
 *
 *  @note:  If you have more than one `widgetID` on the same page, then you should use `+requestWithURL:widgetID:widgetIndex:` instead
 **/
+ (instancetype)requestWithURL:(NSString *)url widgetID:(NSString *)widgetId;

/**
 *  Discussion:
 *      Convenience creator for defining an `OBRequest` object
 *
 *  Params:
 *      @url - The link that you wish to request recommendations for
 *      @widgetId - The widgetID (given by outbrain) to request recommendations for
 *      @widgetIndex - The index of the `widgetID` on the current page.  
 *          (e.g if you have inline widgets, then the first one would be 0, then 1 and so on)
 **/
+ (instancetype)requestWithURL:(NSString *)url widgetID:(NSString *)widgetId widgetIndex:(NSInteger)widgetIndex;



@end




/**
 *  Discussion:
 *      This section should only be used after you have talked to your
 *      outbrain administrator.
 **/

@interface OBRequest (AdvancedNativeSupport)

/**
 *  Discussion:
 *      The mobile content id for this request as it pertains to your app.
 *      For instance if your app looks content up in core data by id, then you would
 *      set this to the id of the object you're requeting for
 **/
@property (nonatomic, copy) NSString * mobileId;

/**
 *  Discussion:
 *      A unique identifier (as it pertains to your application) to 'group'
 *      this piece of content.
 **/
@property (nonatomic, copy) NSString * source;

@end




