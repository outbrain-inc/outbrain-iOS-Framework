#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef OUTBRAINSDK_SWIFT_H
#define OUTBRAINSDK_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreFoundation;
@import Foundation;
@import ObjectiveC;
@import UIKit;
@import WebKit;
#endif

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="OutbrainSDK",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
@class NSString;

SWIFT_CLASS("_TtC11OutbrainSDK12OBDisclosure")
@interface OBDisclosure : NSObject
@property (nonatomic, copy) NSString * _Nullable imageUrl;
@property (nonatomic, copy) NSString * _Nullable clickUrl;
- (nonnull instancetype)initWithImageUrl:(NSString * _Nullable)imageUrl clickUrl:(NSString * _Nullable)clickUrl OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

enum OBErrorType : NSInteger;
enum OBErrorCode : NSInteger;

SWIFT_CLASS("_TtC11OutbrainSDK7OBError")
@interface OBError : NSObject
@property (nonatomic, readonly) enum OBErrorType type;
@property (nonatomic, readonly, copy) NSString * _Nullable message;
@property (nonatomic, readonly) enum OBErrorCode code;
- (nonnull instancetype)initWithType:(enum OBErrorType)type message:(NSString * _Nullable)message code:(enum OBErrorCode)code OBJC_DESIGNATED_INITIALIZER;
+ (OBError * _Nonnull)genericWithMessage:(NSString * _Nullable)message code:(enum OBErrorCode)code SWIFT_WARN_UNUSED_RESULT;
+ (OBError * _Nonnull)networkWithMessage:(NSString * _Nullable)message code:(enum OBErrorCode)code SWIFT_WARN_UNUSED_RESULT;
+ (OBError * _Nonnull)nativeWithMessage:(NSString * _Nullable)message code:(enum OBErrorCode)code SWIFT_WARN_UNUSED_RESULT;
+ (OBError * _Nonnull)zeroRecommendationsWithMessage:(NSString * _Nullable)message code:(enum OBErrorCode)code SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM(NSInteger, OBErrorCode, open) {
  OBErrorCodeGeneric = 10200,
  OBErrorCodeParsing = 10201,
  OBErrorCodeServer = 10202,
  OBErrorCodeInvalidParameters = 10203,
  OBErrorCodeNoRecommendations = 10204,
  OBErrorCodeNoData = 10205,
  OBErrorCodeNetwork = 10206,
};

typedef SWIFT_ENUM(NSInteger, OBErrorType, open) {
  OBErrorTypeGeneric = 0,
  OBErrorTypeNetwork = 1,
  OBErrorTypeNative = 2,
  OBErrorTypeZeroRecommendations = 3,
};

@class NSURL;

SWIFT_CLASS("_TtC11OutbrainSDK11OBImageInfo")
@interface OBImageInfo : NSObject
@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly, copy) NSURL * _Nullable url;
@end

@class NSDate;

SWIFT_CLASS("_TtC11OutbrainSDK9OBRequest")
@interface OBRequest : NSObject
@property (nonatomic, copy) NSString * _Nullable url;
@property (nonatomic, copy) NSString * _Nonnull widgetId;
@property (nonatomic) NSInteger widgetIndex;
@property (nonatomic, copy) NSString * _Nullable externalID;
@property (nonatomic, copy) NSDate * _Nullable startDate;
- (nonnull instancetype)initWithUrl:(NSString * _Nullable)url widgetID:(NSString * _Nonnull)widgetID widgetIndex:(NSInteger)widgetIndex externalID:(NSString * _Nullable)externalID startDate:(NSDate * _Nullable)startDate OBJC_DESIGNATED_INITIALIZER;
+ (OBRequest * _Nonnull)requestWithURL:(NSString * _Nullable)url widgetID:(NSString * _Nonnull)widgetID SWIFT_WARN_UNUSED_RESULT;
+ (OBRequest * _Nonnull)requestWithURL:(NSString * _Nullable)url widgetID:(NSString * _Nonnull)widgetID widgetIndex:(NSInteger)widgetIndex SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC11OutbrainSDK17OBPlatformRequest")
@interface OBPlatformRequest : OBRequest
@property (nonatomic, copy) NSString * _Nullable contentUrl;
@property (nonatomic, copy) NSString * _Nullable portalUrl;
@property (nonatomic, copy) NSString * _Nullable bundleUrl;
@property (nonatomic, copy) NSString * _Nullable lang;
@property (nonatomic, copy) NSString * _Nullable psub;
- (nonnull instancetype)initWithWidgetID:(NSString * _Nonnull)widgetID widgetIndex:(NSInteger)widgetIndex contentUrl:(NSString * _Nullable)contentUrl portalUrl:(NSString * _Nullable)portalUrl bundleUrl:(NSString * _Nullable)bundleUrl lang:(NSString * _Nullable)lang psub:(NSString * _Nullable)psub OBJC_DESIGNATED_INITIALIZER;
+ (OBPlatformRequest * _Nonnull)requestWithBundleURL:(NSString * _Nonnull)bundleUrl lang:(NSString * _Nonnull)lang widgetID:(NSString * _Nonnull)widgetID SWIFT_WARN_UNUSED_RESULT;
+ (OBPlatformRequest * _Nonnull)requestWithPortalURL:(NSString * _Nonnull)portalUrl lang:(NSString * _Nonnull)lang widgetID:(NSString * _Nonnull)widgetID SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)initWithUrl:(NSString * _Nullable)url widgetID:(NSString * _Nonnull)widgetID widgetIndex:(NSInteger)widgetIndex externalID:(NSString * _Nullable)externalID startDate:(NSDate * _Nullable)startDate SWIFT_UNAVAILABLE;
@end


SWIFT_CLASS("_TtC11OutbrainSDK16OBRecommendation")
@interface OBRecommendation : NSObject
@property (nonatomic, copy) NSString * _Nullable url;
@property (nonatomic, copy) NSString * _Nullable origUrl;
@property (nonatomic, copy) NSString * _Nullable content;
@property (nonatomic, copy) NSString * _Nullable source;
@property (nonatomic, strong) OBImageInfo * _Nullable image;
@property (nonatomic, copy) NSString * _Nullable position;
@property (nonatomic, copy) NSString * _Nullable author;
@property (nonatomic, copy) NSDate * _Nullable publishDate;
@property (nonatomic) BOOL sameSource;
@property (nonatomic, strong) OBDisclosure * _Nullable disclosure;
@property (nonatomic, copy) NSArray<NSString *> * _Nullable pixels;
@property (nonatomic, copy) NSString * _Nullable reqId;
@property (nonatomic, readonly) BOOL isPaidLink;
@property (nonatomic, readonly) BOOL isRTB;
@property (nonatomic, readonly) BOOL isVideo;
- (BOOL)shouldDisplayDisclosureIcon SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class OBViewabilityActions;

SWIFT_CLASS("_TtC11OutbrainSDK24OBRecommendationResponse")
@interface OBRecommendationResponse : NSObject
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> * _Nonnull request;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> * _Nonnull settings;
@property (nonatomic, readonly, strong) OBViewabilityActions * _Nullable viewabilityActions;
@property (nonatomic, readonly, copy) NSArray<OBRecommendation *> * _Nonnull recommendations;
@property (nonatomic, strong) OBError * _Nullable error;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end



SWIFT_PROTOCOL("_TtP11OutbrainSDK18OBResponseDelegate_")
@protocol OBResponseDelegate
- (void)outbrainDidReceiveResponseWithSuccess:(OBRecommendationResponse * _Nonnull)response;
- (void)outbrainFailedToReceiveResposneWithError:(OBError * _Nullable)error;
@end

@class NSCoder;

SWIFT_CLASS("_TtC11OutbrainSDK6OBView")
@interface OBView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder SWIFT_UNAVAILABLE;
- (void)removeFromSuperview;
@end


SWIFT_CLASS("_TtC11OutbrainSDK20OBViewabilityActions")
@interface OBViewabilityActions : NSObject
@property (nonatomic, readonly, copy) NSString * _Nullable reportServed;
@property (nonatomic, readonly, copy) NSString * _Nullable reportViewed;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC11OutbrainSDK8Outbrain")
@interface Outbrain : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull OB_SDK_VERSION;)
+ (NSString * _Nonnull)OB_SDK_VERSION SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable customUserId;)
+ (NSString * _Nullable)customUserId SWIFT_WARN_UNUSED_RESULT;
+ (void)setCustomUserId:(NSString * _Nullable)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable partnerKey;)
+ (NSString * _Nullable)partnerKey SWIFT_WARN_UNUSED_RESULT;
+ (void)setPartnerKey:(NSString * _Nullable)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL testMode;)
+ (BOOL)testMode SWIFT_WARN_UNUSED_RESULT;
+ (void)setTestMode:(BOOL)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL testRTB;)
+ (BOOL)testRTB SWIFT_WARN_UNUSED_RESULT;
+ (void)setTestRTB:(BOOL)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL testDisplay;)
+ (BOOL)testDisplay SWIFT_WARN_UNUSED_RESULT;
+ (void)setTestDisplay:(BOOL)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable testLocation;)
+ (NSString * _Nullable)testLocation SWIFT_WARN_UNUSED_RESULT;
+ (void)setTestLocation:(NSString * _Nullable)value;
+ (void)initializeOutbrainWithPartnerKey:(NSString * _Nonnull)partnerKey;
+ (OBError * _Nullable)checkInitiated SWIFT_WARN_UNUSED_RESULT;
+ (void)fetchRecommendationsForRequest:(OBRequest * _Nonnull)request withCallback:(void (^ _Nullable)(OBRecommendationResponse * _Nonnull))callback;
+ (void)fetchRecommendationsForRequest:(OBRequest * _Nonnull)request withDelegate:(id <OBResponseDelegate> _Nonnull)delegate;
+ (NSURL * _Nullable)getUrl:(OBRecommendation * _Nonnull)rec SWIFT_WARN_UNUSED_RESULT;
+ (NSURL * _Nullable)getOutbrainAboutURL SWIFT_WARN_UNUSED_RESULT;
+ (NSURL * _Nullable)getAboutURL SWIFT_WARN_UNUSED_RESULT;
+ (void)configureViewabilityPerListingFor:(UIView * _Nonnull)view withRec:(OBRecommendation * _Nonnull)rec;
+ (void)printLogsWithDomain:(NSString * _Nullable)domain;
+ (void)testRTB:(BOOL)testRTB;
+ (void)testLocation:(NSString * _Nonnull)testLocation;
+ (void)testDisplay:(BOOL)testDisplay;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@protocol SFWidgetDelegate;
@class UIScrollView;
@protocol UIViewControllerTransitionCoordinator;

SWIFT_CLASS("_TtC11OutbrainSDK8SFWidget")
@interface SFWidget : UIView
@property (nonatomic, readonly) CGFloat currentHeight;
@property (nonatomic, copy) NSString * _Nullable webviewUrl;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL infiniteWidgetsOnTheSamePage;)
+ (BOOL)infiniteWidgetsOnTheSamePage SWIFT_WARN_UNUSED_RESULT;
+ (void)setInfiniteWidgetsOnTheSamePage:(BOOL)value;
/// External Id public value
/// app developer should set “external ID” and the optional “secondary external ID” as shown below:
@property (nonatomic, copy) NSString * _Nullable extId;
@property (nonatomic, copy) NSString * _Nullable extSecondaryId;
/// Outbrain uses the odb parameter pubImpId to get the session ID/ click identifier from the publisher.
@property (nonatomic, copy) NSString * _Nullable OBPubImp;
/// Initializes a new instance of the custom view with the specified frame.
/// This initializer sets up the view’s initial state and invokes the common initialization method.
/// Usage Example:
/// let customView = CustomView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
/// *
/// \param frame A <code>CGRect</code> that defines the initial size and position of the view within its superview’s coordinate system.
///
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
/// Initializes a new instance of the custom view based on data from the storyboard or a NIB file.
/// This required initializer is called when the view is created from a storyboard or NIB file. It invokes the common initialization method to set up the view’s initial state.
/// important:
/// You should not override this initializer unless necessary.
/// <ul>
///   <li>
///   </li>
/// </ul>
/// \param coder An <code>NSCoder</code> object used to decode the view from an archive.
///
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
/// Configures the custom widget with the provided settings.
/// This method allows you to configure the custom widget with the provided settings, such as the delegate, URL, widget ID, and installation key. Additional configuration options are set to their default values. Use this method when you want to quickly configure the widget with basic settings.
/// note:
/// If you need to configure more advanced options, consider using the <code>configure</code> method with additional parameters.
/// Usage Example:
/// \code
/// widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", installationKey: "abcdef")
///
///
/// \endcode\param delegate An object conforming to the <code>SFWidgetDelegate</code> protocol that will handle widget events and interactions.
///
/// \param url The URL associated with the widget.
///
/// \param widgetId A unique identifier for the widget.
///
/// \param installationKey A key used for widget installation.
///
- (void)configureWith:(id <SFWidgetDelegate> _Nonnull)delegate url:(NSString * _Nonnull)url widgetId:(NSString * _Nonnull)widgetId installationKey:(NSString * _Nonnull)installationKey;
/// Configures the custom widget with advanced settings.
/// Use this method to configure the custom widget with advanced settings beyond the basic configuration. You can specify the delegate, URL, widget ID, widget index, installation key, user ID, and dark mode preference.
/// note:
/// If you want to use this widget in a SwiftUI environment, set <code>isSwiftUI</code> to <code>true</code> when calling this method.
/// Usage Example:
/// \code
/// widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", widgetIndex: 0, installationKey: "abcdef", userId: "user123", darkMode: true)
///
///
/// \endcode\param delegate An object conforming to the <code>SFWidgetDelegate</code> protocol that will handle widget events and interactions.
///
/// \param url The URL associated with the widget.
///
/// \param widgetId A unique identifier for the widget.
///
/// \param widgetIndex An integer representing the index of the widget.
///
/// \param installationKey A key used for widget installation.
///
/// \param userId An optional user identifier, if applicable.
///
/// \param darkMode A boolean indicating whether the widget should be displayed in dark mode.
///
- (void)configureWith:(id <SFWidgetDelegate> _Nullable)delegate url:(NSString * _Nonnull)url widgetId:(NSString * _Nonnull)widgetId widgetIndex:(NSInteger)widgetIndex installationKey:(NSString * _Nonnull)installationKey userId:(NSString * _Nullable)userId darkMode:(BOOL)darkMode;
/// Configures the custom widget with advanced settings.
/// Use this method to configure the custom widget with advanced settings. You can specify the delegate, URL, widget ID, installation key, widget index, user ID, dark mode, and SwiftUI integration.
/// If you do not provide a delegate, certain widget interactions may not be handled. The user ID, dark mode, and SwiftUI integration are optional and can be omitted if not needed.
/// note:
/// After configuring the widget, you should call the <code>initialLoadUrl</code> method to load the widget content.
/// Usage Example:
/// \code
/// widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", widgetIndex: 0, installationKey: "abcdef", userId: "user123", darkMode: true)
///
///
/// \endcode\param delegate An optional object conforming to the <code>SFWidgetDelegate</code> protocol that will handle widget events and interactions.
///
/// \param url The URL associated with the widget.
///
/// \param widgetId A unique identifier for the widget.
///
/// \param widgetIndex An integer representing the index of the widget.
///
/// \param installationKey A key used for widget installation.
///
/// \param userId An optional user identifier associated with the widget.
///
/// \param darkMode A Boolean flag indicating whether to enable dark mode for the widget.
///
/// \param isSwiftUI A Boolean flag indicating whether the widget is integrated with SwiftUI.
///
- (void)configureWith:(id <SFWidgetDelegate> _Nullable)delegate url:(NSString * _Nonnull)url widgetId:(NSString * _Nonnull)widgetId widgetIndex:(NSInteger)widgetIndex installationKey:(NSString * _Nonnull)installationKey userId:(NSString * _Nullable)userId darkMode:(BOOL)darkMode isSwiftUI:(BOOL)isSwiftUI SWIFT_DEPRECATED_MSG("Please use configure(with delegate: SFWidgetDelegate?, url: String, widgetId: String, widgetIndex: Int, installationKey: String, userId: String?, darkMode: Bool)  instead.");
+ (void)enableFlutterModeWithFlutter_packageVersion:(NSString * _Nonnull)flutter_packageVersion;
+ (void)enableReactNativeModeWithRN_packageVersion:(NSString * _Nonnull)RN_packageVersion;
- (CGFloat)getCurrentHeight SWIFT_WARN_UNUSED_RESULT;
- (void)didMoveToWindow;
- (void)didMoveToSuperview;
- (void)enableEvents;
- (void)toggleDarkMode:(BOOL)isDark;
- (void)scrollViewDidScroll:(UIScrollView * _Nonnull)scrollView SWIFT_DEPRECATED_MSG("Please remove any calls to this method.");
- (void)reportPageViewOnTheSameWidget;
- (void)loadMore;
- (void)observeValueForKeyPath:(NSString * _Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey, id> * _Nullable)change context:(void * _Nullable)context;
- (void)viewWillTransitionTo:(CGSize)size with:(id <UIViewControllerTransitionCoordinator> _Nonnull)coordinator;
@end


@class SFWidgetTableCell;
@class SFWidgetCollectionCell;

@interface SFWidget (SWIFT_EXTENSION(OutbrainSDK))
- (void)willDisplayCell:(SFWidgetTableCell * _Nonnull)cell;
- (void)willDisplayCollectionViewCell:(SFWidgetCollectionCell * _Nonnull)cell;
@end

@class WKWebView;
@class WKWebViewConfiguration;
@class WKNavigationAction;
@class WKWindowFeatures;

@interface SFWidget (SWIFT_EXTENSION(OutbrainSDK)) <WKNavigationDelegate, WKUIDelegate>
- (WKWebView * _Nullable)webView:(WKWebView * _Nonnull)webView createWebViewWithConfiguration:(WKWebViewConfiguration * _Nonnull)configuration forNavigationAction:(WKNavigationAction * _Nonnull)navigationAction windowFeatures:(WKWindowFeatures * _Nonnull)windowFeatures SWIFT_WARN_UNUSED_RESULT;
- (void)webView:(WKWebView * _Nonnull)webView decidePolicyForNavigationAction:(WKNavigationAction * _Nonnull)navigationAction decisionHandler:(void (^ _Nonnull)(WKNavigationActionPolicy))decisionHandler;
@end


SWIFT_PROTOCOL("_TtP11OutbrainSDK16SFWidgetDelegate_")
@protocol SFWidgetDelegate
/// @brief called on recommendation “click” inside the feed. Publisher should open the URL in an external browser.
/// @param url - the “click URL” of the recommendation, the publisher should open the URL in an external browser.
- (void)onRecClick:(NSURL * _Nonnull)url;
@optional
/// @brief (Optional) called when the “feed widget” inside the WebView changed its height. Publisher might want to be notified when the SFWidget changes its height.
/// @param newHeight - the updated height for the SFWidget
- (void)didChangeHeight:(CGFloat)newHeight;
/// @brief (Optional) called when the “feed widget” inside the WebView changed its height. Publisher might want to be notified when the SFWidget changes its height.
/// @deprecated - please use didChangeHeight:(CGFloat) newHeight
- (void)didChangeHeight SWIFT_DEPRECATED_MSG("Please use didChangeHeight(_ newHeight: CGFloat) instead.");
/// @brief (Optional) publisher may choose to “catch” clicks on “organic recommendations” in order to navigate the user to the clicked recommendation INSIDE the app (instead of the default behavior of openning the link in an external browser)
/// @param url - the organic rec “article url”, i.e. the aricle url we should navigate to within the app navigation stack.
- (void)onOrganicRecClick:(NSURL * _Nonnull)url;
/// @brief (Optional) called when the JS widget inside the WKWebView dispatch widget events (for example: rendered, error, viewability, etc).
/// it should be implemented only if the publisher would like to manually keep track of widget events.
/// @param eventName - the name of the event being dispatched
/// @param additionalData - additional data that comes with the event. For example you’ll find there: “widget ID”, “widget index” and “timestamp”.
- (void)widgetEvent:(NSString * _Nonnull)eventName additionalData:(NSDictionary<NSString *, id> * _Nonnull)additionalData;
@end


@interface SFWidget (SWIFT_EXTENSION(OutbrainSDK))
- (void)onRecClick:(NSURL * _Nonnull)url;
- (void)onSettingsReceived:(NSDictionary<NSString *, id> * _Nonnull)settings;
@end


SWIFT_CLASS("_TtC11OutbrainSDK22SFWidgetCollectionCell")
@interface SFWidgetCollectionCell : UICollectionViewCell
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end



SWIFT_CLASS("_TtC11OutbrainSDK17SFWidgetTableCell")
@interface SFWidgetTableCell : UITableViewCell
- (void)awakeFromNib;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (nonnull instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString * _Nullable)reuseIdentifier OBJC_DESIGNATED_INITIALIZER SWIFT_AVAILABILITY(ios,introduced=3.0);
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC11OutbrainSDK16SFWidgetTestMode")
@interface SFWidgetTestMode : SFWidget
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end


#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#else
#error unsupported Swift architecture
#endif
