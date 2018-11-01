//
//  GDPRUtils.h
//  GDPR
//

#import <Foundation/Foundation.h>

/**
 Object that provides the interface for storing and retrieving GDPR-related information
 */
@interface GDPRUtils : NSObject

typedef NS_ENUM(NSInteger, SubjectToGDPR) {
    SubjectToGDPR_Unknown = -1,
    SubjectToGDPR_No = 0,
    SubjectToGDPR_Yes = 1
};

+(GDPRUtils *) sharedInstance;

@property (nonatomic, retain) NSUserDefaults *userDefaults;

/**
 The consent string passed as a websafe base64-encoded string.
 */
@property (nonatomic, readonly) NSString *consentString;

/**
 Enum that indicates    'SubjectToGDPR_Unknown'- value -1, unset.
                        'SubjectToGDPR_No' – value 0, not subject to GDPR
                        'SubjectToGDPR_Yes' – value 1, subject to GDPR,
 */
@property (nonatomic, readonly) SubjectToGDPR subjectToGDPR;

/**
 String that contains the consent information for all vendors.
 */
@property (nonatomic, readonly) NSString *parsedVendorConsents;

/**
 String that contains the consent information for all purposes.
 */
@property (nonatomic, readonly) NSString *parsedPurposeConsents;

/**
 Boolean that indicates if a CMP implementing the iAB specification is present in the application
 */
@property (nonatomic, assign, readonly) BOOL cmpPresent;

/**
 Returns true if user consent has been given to vendor
 */
- (BOOL)isVendorConsentGivenFor:(int)vendorId;

/**
 Returns true if user consent has been given for purpose
 */
- (BOOL)isPurposeConsentGivenFor:(int)purposeId;

@end
