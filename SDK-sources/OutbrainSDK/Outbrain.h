//
//  OutbrainSDK.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/9/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <Foundation/NSArray.h>
#import <UIkit/UIkit.h>
#import "OBProtocols.h"


@class OBLabel;
@class OBRequest;
@class OBResponse;
@class OBRecommendation;

// The current version of the sdk
extern NSString * _Nonnull const OB_SDK_VERSION;

extern NSString * _Nonnull const OB_AD_NETWORK_ID;

#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

/**
 @brief OBSDK's main interface; for fetching content recommendations and reporting clicks.
 
 The Outbrain SDK must be initialized and registered (by calling __initializeOutbrainWithPartnerKey__) \n
	when your app is initialized.\n
 Call __fetchRecommendationsForRequest__ to retrieve content recommendations.\n
 
 @note Please see the "Outbrain iOS SDK Programming Guide" for more detailed explanations about how to integrate with Outbrain.
 
 **/
@interface Outbrain : NSObject

/** @section Initialize **/


/**
 *  @brief Initializes Outbrain with the partner key you've received from your Outbrain Account Manager.
 *
 *  A partner key uniquely identifies an Outbrain customer.
 *
 *  @note Call this method once during your app's initialization, before calling any other method. The best practice is to call it \n
 *  in the onCreate function of the first Activity, or when generating the ApplicationContext, if your app has one.
 *
 *  @param partnerKey - the partner key you've received from your Outbrain Account Manager.
 *
 *  @see initializeOutbrainWithConfigFile
 **/
+ (void)initializeOutbrainWithPartnerKey:(NSString * _Nonnull)partnerKey;

/**
 *  @brief Check if SDK was initilized
 *
 **/
+ (BOOL) SDKInitialized;

/** @section Fetching **/

/**
 * @brief Retrieves content recommendations.
 *
 * When calling this method, you must supply either a OBResponseCompletionHandler callback handler, or a OBResponseDelegate delegate,\n
 * to handle the recommendations response.\n
 *
 * @note Although the __fetchRecommendationsForRequest__ requests are asynchronous, they are all stored\n
 * in the same queue, so they are handled in the order in which they were called.
 *
 * @param request - the request object.
 *
 * @see OBRequest
 * @see OBResponseCompletionHandler
 * @see OBResponseDelegate
 */
+ (void)fetchRecommendationsForRequest:(OBRequest * _Nonnull)request
                          withCallback:(OBResponseCompletionHandler _Nonnull )handler;

+ (void)fetchRecommendationsForRequest:(OBRequest * _Nonnull)request
                          withDelegate:(__weak id<OBResponseDelegate> _Nonnull)delegate;


/** @section Viewability **/

/**
 * @brief Register OBLabel with the corresponding widgetId and url of the current page
 *
 * OBLabel is the view publisher should place in the header of a recommandations view widget.
 * This function Registers the OBLabel with the corresponding widgetId and url of the screen
 * so that analytics reports to the server will match with the actual data the user used in the app.
 * (See the Outbrain Journal sample app for an example of how to do this.)
 *
 * @param widgetId - The Widget Id to be associated with this OBLabel
 * @param url - The URL that the user is currently viewing
 **/
+ (void) registerOBLabel:(OBLabel * _Nonnull)label withWidgetId:(NSString * _Nonnull)widgetId andUrl:(NSString * _Nonnull)url __deprecated_msg("use registerOBLabel:withOBRequest: instead.");

/**
 * @brief Register OBLabel with the corresponding OBRequest for the recommendations to be displayed in this widget.
 *
 * OBLabel is the view publisher should place in the header of a recommandations view widget.
 * This function Registers the OBLabel with the corresponding OBRequest for the recommendations to be displayed in this widget,
 * so that analytics reports to the server will match with the actual data the user used in the app.
 * (See the Outbrain Journal sample app for an example of how to do this.)
 *
 * @param obRequest - The OBRequest to be associated with this OBLabel
 **/
+ (void) registerOBLabel:(OBLabel * _Nonnull)label withOBRequest:(OBRequest * _Nonnull)obRequest;

/** @section Click Handling **/

/**
 * @brief Maps the given OBRecommendation object to the URL, and for organic recommendation, register the click to traffic.outbrain
 *
 * This function returns the recommendation's URL and for organic recommendation, register the click to traffic.outbrain
 * Open paid links in a web view or external browser.\n
 * In the case of an organic link, translate the web URL into a mobile URL (if necessary) and show the content natively. \n
 * (See the Outbrain Journal sample app for an example of how to do this.)
 *
 * @param recommendation - a pointer to the the OBRecommendation object representing the recommendation that has been clicked.
 * @note If you open a new view as a result of the user clicking on a recommendation, call this method to get the URL.
 * @note It is recommended that your app hold the OBRecommendationResponse object as an instance variable in the Activity.
 *
 * @return The web URL to redirect to.
 * @note If it's necessary to map the web URL to a mobile URL, this must be done in your code.
 * @see OBRecommendation
 **/
+ (NSURL * _Nullable) getUrl:(OBRecommendation * _Nonnull)recommendation;


/**
 * @brief Get the URL you should open in an external browser when the user taps on Outbrain logo
 *
 * This function creates the URL to be opened in an external browser when the user taps on Outbrain logo.
 * The URL contains the user Advertiser ID param which is mandatory for Ad Choices opt-out compliance.
 *
 *
 * @return The URL to be opened in an external browser
 **/
+(NSURL * _Nonnull) getOutbrainAboutURL;

/**
 * @brief Activates/deactivates the Outbrain test mode.
 *
 * Activate test mode while developing and testing your app. \n
 * This prevents Outbrain from performing operational actions such as reporting and billing.
 *
 * @param testMode - a boolean flag; set to true to activate test mode, or false to deactivate test mode.
 */
+ (void)setTestMode:(BOOL)testMode;

/**
 * @brief Activates/deactivates RTB recs simultation
 *
 * Setting this flag to "true" will force every Outbrain response (ODB) to include at least 1 RTB rec
 *
 * @param testRTB - a boolean flag; set to true to activate test mode, or false to deactivate test mode.
 */
+ (void)testRTB:(BOOL)testRTB;

/**
 * @brief Simulate Geo by setting location (country code, for example: "us")
 *
 * Setting location will cause all ODB requests to be sent with the "location" param set to this value
 *
 * @param location - country code, for example: "us"
 */
+ (void)testLocation:(NSString * _Nonnull)location;

/**
 * @brief Used for "App install" ads, on click the app developer should call this method to open the advertiser app via loadProduct method
 *
 * App developer must call this method if (rec.isAppInstall) is "true" after a recommendation click.
 *
 * @param rec - the rec the user has clicked on
 * @param navController - the app navigation controller the app ad should open in.
 */
+(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inNavController:(UINavigationController * _Nonnull)navController;


@end
