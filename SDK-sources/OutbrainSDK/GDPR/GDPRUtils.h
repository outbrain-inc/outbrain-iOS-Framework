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
@property (nonatomic, readonly) NSString *gdprV1ConsentString;

/**
 The consent string passed as a websafe base64-encoded string.
 */
@property (nonatomic, readonly) NSString *gdprV2ConsentString;

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

/**
 * https://iabtechlab.com/wp-content/uploads/2019/10/CCPA_Compliance_Framework_US_Privacy_USER_SIGNAL_API_SPEC_IABTechLab_DRAFT_for_Public_Comment.pdf
 * iAB US Privacy String (CCPA)
 */
@property (nonatomic, readonly) NSString *ccpaPrivacyString;

@property (nonatomic, readonly) NSString *gppSectionsString;

@property (nonatomic, readonly) NSString *gppPrivacyString;

@end
