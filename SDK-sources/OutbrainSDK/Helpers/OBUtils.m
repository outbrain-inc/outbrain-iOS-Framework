//
//  OBUtils.m
//  OutbrainSDK
//
//  Created by oded regev on 11/20/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBUtils.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation OBUtils

+(NSString *) deviceModel {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",        // (Original)
                              @"iPod2,1"   :@"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" :@"iPhone",            // (Original)
                              @"iPhone1,2" :@"iPhone",            // (3G)
                              @"iPhone2,1" :@"iPhone",            // (3GS)
                              @"iPad1,1"   :@"iPad",              // (Original)
                              @"iPad2,1"   :@"iPad 2",            //
                              @"iPad3,1"   :@"iPad",              // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",          // (GSM)
                              @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",         //
                              @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",              // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",         // (Original)
                              @"iPhone5,3" :@"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",     //
                              @"iPhone7,2" :@"iPhone 6",          //
                              @"iPhone8,1" :@"iPhone 6S",         //
                              @"iPhone8,2" :@"iPhone 6S Plus",    //
                              @"iPhone8,4" :@"iPhone SE",         //
                              @"iPhone9,1" :@"iPhone 7",          //
                              @"iPhone9,3" :@"iPhone 7",          //
                              @"iPhone9,2" :@"iPhone 7 Plus",     //
                              @"iPhone9,4" :@"iPhone 7 Plus",     //
                              @"iPhone10,1": @"iPhone 8",          // CDMA
                              @"iPhone10,4": @"iPhone 8",          // GSM
                              @"iPhone10,2": @"iPhone 8 Plus",     // CDMA
                              @"iPhone10,5": @"iPhone 8 Plus",     // GSM
                              @"iPhone10,3": @"iPhone X",          // CDMA
                              @"iPhone10,6": @"iPhone X",          // GSM
                              @"iPhone11,2": @"iPhone XS",
                              @"iPhone11,4": @"iPhone XS Max",
                              @"iPhone11,6": @"iPhone XS Max Global",
                              @"iPhone11,8": @"iPhone XR",
                              
                              @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    
    return deviceName;
    
}

+(NSString *) decodeHTMLEnocdedString:(NSString *)htmlEncodedString {
    NSString *result = [self stripHTMLTags:[self replaceCommonHTMLEntities:htmlEncodedString]];
    return result;
}

+(NSString *) stripHTMLTags:(NSString *)inputString {
    if (inputString == nil || inputString.length == 0) {
        return @"";
    }
    
    static NSRegularExpression *htmlRegex = nil;
    static NSString *htmlRegexPattern = @"(<(?:\"[^\"]*\"['\"]*|'[^']*'['\"]*|[^'\">])+>|&.*?;)";
    
    if (htmlRegex == nil) {
        htmlRegex = [NSRegularExpression regularExpressionWithPattern:htmlRegexPattern options:0 error:nil];
    }
    
    NSString *result = [htmlRegex stringByReplacingMatchesInString:inputString
                                                           options:0
                                                             range:NSMakeRange(0, inputString.length)
                                                      withTemplate:@""];
    
    return result ?: @"";
}

+(NSString *) replaceCommonHTMLEntities:(NSString *)inputString {
    if (inputString == nil || inputString.length == 0) {
        return nil;
    }
    
    static NSDictionary *characterMapping = nil;
    
    if (characterMapping == nil) {
        /// https://brajeshwar.github.io/entities/
        characterMapping = @{@"&quot;": @"\"", @"&#34;": @"\"",
                             @"&num;": @"#", @"&#35;": @"#",
                             @"&dollar;": @"$", @"&#36;": @"$",
                             @"&percnt;": @"%", @"&#37;": @"%",
                             @"&amp;": @"&", @"&#38;": @"&",
                             @"&apos;": @"'", @"&#39;": @"'",
                             @"&lpar;": @"(", @"&#40;": @"(",
                             @"&rpar;": @")", @"&#41;": @")",
                             @"&ast;": @"*", @"&#42;": @"*",
                             @"&plus;": @"+", @"&#43;": @"+",
                             @"&comma;": @",", @"&#44;": @",",
                             @"&minus;": @"-", @"&#45;": @"-",
                             @"&period;": @".", @"&#46;": @".",
                             @"&sol;": @"/", @"&#47;": @"/",
                             @"&colon;": @":", @"&#58;": @":",
                             @"&semi;": @";", @"&#59;": @";",
                             @"&lt;": @"<", @"&#60;": @"<",
                             @"&equals;": @"=", @"&#61;": @"=",
                             @"&gt;": @">", @"&#62;": @">",
                             @"&quest;": @"?", @"&#63;": @"?",
                             @"&commat;": @"@", @"&#64;": @"@",
                             @"&lsqb;": @"[", @"&#91;": @"[",
                             @"&bsol;": @"\\", @"&#92;": @"\\",
                             @"&rsqb;": @"]", @"&#93;": @"]",
                             @"&Hat;": @"^", @"&#94;": @"^",
                             @"&lowbar;": @"_", @"&#95;": @"_",
                             @"&grave;": @"`", @"&#96;": @"`",
                             @"&lcub;": @"{", @"&#123;": @"{",
                             @"&verbar;": @"|", @"&#124;": @"|",
                             @"&rcub;": @"}", @"&#125;": @"}",
                             @"&#126;": @"~", @"&#x2018;" : @"‘",
                             @"&#x2019;" : @"’"
                             };
    }
    
    NSString *result = [NSString stringWithString:inputString];
    
    for (NSString *key in characterMapping) {
        result = [result stringByReplacingOccurrencesOfString:key withString:characterMapping[key]];
    }
    
    return result ?: @"";
}

@end
