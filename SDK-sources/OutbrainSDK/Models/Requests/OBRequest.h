//
//  OBWidget.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @brief This class contains all the details required to produce content recommendations.
 *
 * It is passed as a parameter to __fetchRecommendationsForRequest__.\n
 * Its properties are:\n
 * <ul>
 *    <li><strong>url</strong> - the URL that the user is currently viewing.\n
 *    <li><strong>widgetIndex</strong> - the page view widget index. You must assign unique, sequential numeric IDs to the widgets on your page, to be passed to Outbrain.\n
 *          	This prevents recommendation requests from being duplicated for the same widget.\n
 *    <li><strong>widgetId</strong> - a string ID for the widget in which content recommendations will be displayed. This ID is assigned by your account manager.\n
 *		    	(Please consult with your account manager if you do not know your widgetIds.)\n
 *			    The widgetId is mapped to configuration settings that define how recommendations will be displayed (e.g. with or without thumbnail images).\n
 *    <li><strong>additionalData</strong> - custom data that you want to associate with the viewed URL.\n
 *                                          Outbrain stores this value and returns it if and when this URL is returned as a recommendation.
 *    <li><strong>mobileSubgroup</strong> - an identifier for the subset of your organic links that may be used within mobile apps. (Discuss this value with your Outbrain account manager.)
 * </ul>
 *
 * @note The mandatory properties (which must be provided to the __OBRequest__ constructor) are __url__ and __widgetId__.
 *
 * @note Please see the "Outbrain Android SDK Programming Guide" for more detailed explanations about how to integrate with Outbrain.
 *
 *
 * @see Outbrain::fetchRecommendationsForRequest
 * @see OBRecommendationResponse
 */
@interface OBRequest : NSObject {
}

/**
 *  @brief The URL that the user is currently viewing (default value is NULL).
 **/
@property (nonatomic, copy) NSString * url;

/**
 * @brief A string ID (assigned by your account manager) for the widget in which content recommendations will be displayed (default value is NULL).
 **/
@property (nonatomic, copy) NSString * widgetId;

/**
 *  @brief A zero-based, unique numeric ID for the widget in which content recommendations will be displayed (default value is 0).
 *
 *  @note This is only necessary if there is more than one widget with the same widgetID on the same page.
 **/
@property (nonatomic, assign) NSInteger widgetIndex;


/**
 *  @brief A constructor for defining an OBRequest object.
 *
 *  @param url - the URL that the user is currently viewing.
 *  @param widgetId - a string ID (assigned by your account manager) for the widget in which content recommendations will be displayed.
 *
 *  @note: If you have more than one widgetID on the same page, use the next constructor (with a widgetIndex parameter) instead.
 **/
+ (instancetype)requestWithURL:(NSString *)url widgetID:(NSString *)widgetId;

/**
 *  @brief A constructor for defining an OBRequest object.
 *
 *  @param url - the URL that the user is currently viewing.
 *  @param widgetId - a string ID (assigned by your account manager) for the widget in which content recommendations will be displayed.
 *  @param widgetIndex - the numeric index of the widget on the current page.
 **/
+ (instancetype)requestWithURL:(NSString *)url widgetID:(NSString *)widgetId widgetIndex:(NSInteger)widgetIndex;

@end
