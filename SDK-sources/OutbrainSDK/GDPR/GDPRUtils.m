//
//  GDPRUtils.m
//  GDPR
//

#import "GDPRUtils.h"

NSString *const IABConsent_SubjectToGDPRKey = @"IABConsent_SubjectToGDPR";
NSString *const IABConsent_ConsentStringKey = @"IABConsent_ConsentString";
NSString *const IABConsent_ParsedVendorConsentsKey = @"IABConsent_ParsedVendorConsents";
NSString *const IABConsent_ParsedPurposeConsentsKey = @"IABConsent_ParsedPurposeConsents";
NSString *const IABConsent_CMPPresentKey = @"IABConsent_CMPPresent";

@implementation GDPRUtils

+(GDPRUtils *) sharedInstance {
    static GDPRUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSString *)consentString {
    return [self.userDefaults objectForKey:IABConsent_ConsentStringKey];
}

-(SubjectToGDPR)subjectToGDPR {
    NSString *subjectToGDPRAsString = [self.userDefaults objectForKey:IABConsent_SubjectToGDPRKey];
    
    if (subjectToGDPRAsString != nil) {
        if ([subjectToGDPRAsString isEqualToString:@"0"]) {
            return SubjectToGDPR_No;
        } else if ([subjectToGDPRAsString isEqualToString:@"1"]) {
            return SubjectToGDPR_Yes;
        } else {
            return SubjectToGDPR_Unknown;
        }
    } else {
        return SubjectToGDPR_Unknown;
    }
}

-(BOOL)cmpPresent {
    return [[self.userDefaults objectForKey:IABConsent_CMPPresentKey] boolValue];
}

-(NSString *)parsedVendorConsents {
    return [self.userDefaults objectForKey:IABConsent_ParsedVendorConsentsKey];
}

-(NSString *)parsedPurposeConsents {
    return [self.userDefaults objectForKey:IABConsent_ParsedPurposeConsentsKey];
}

- (BOOL)isVendorConsentGivenFor:(int)vendorId {
    NSString *vendorConsentBits = self.parsedVendorConsents;
    if (!vendorConsentBits || vendorConsentBits.length < vendorId) {
        return NO;
    }
    
    return [[vendorConsentBits substringWithRange:NSMakeRange(vendorId-1, 1)] boolValue];
}

- (BOOL)isPurposeConsentGivenFor:(int)purposeId {
    NSString *purposeConsentBits = self.parsedPurposeConsents;
    if (!purposeConsentBits || purposeConsentBits.length < purposeId) {
        return NO;
    }
    
    return [[purposeConsentBits substringWithRange:NSMakeRange(purposeId-1, 1)] boolValue];
}

- (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dataStorageDefaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"", IABConsent_ConsentStringKey,
                                                  @"", IABConsent_ParsedVendorConsentsKey,
                                                  @"", IABConsent_ParsedPurposeConsentsKey,
                                                  [NSNumber numberWithBool:NO], IABConsent_CMPPresentKey,
                                                  nil];
        [_userDefaults registerDefaults:dataStorageDefaultValues];
    }
    return _userDefaults;
}

@end
