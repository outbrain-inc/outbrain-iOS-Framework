//
//  OBDefines.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 1/6/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#ifndef OutbrainSDK_OBDefines_h
#define OutbrainSDK_OBDefines_h

#define OBDemoPartnerKey      @"iOSSampleApp2014"

// Here we'll define some things that we'll use for our tests

#define kOBValidWidgetID    @"NA"
#define kOBInvalidWidgetID  @"blah"


#define kOBValidTestLink    @"http://www.webx0.com/2010/07/some-posthype-thoughts-about-flipboard.html"



/**
 *  Here are some convenience helpers for some tests that we do alot.
 *  We're defining these as macros so that we'll get the proper placement within a test.
 **/

#define OBAssertNotNilAndProperClass(obj,class) \
STAssertNotNil(obj,@"Object should not be nil"); \
STAssertTrue([obj isKindOfClass:class],@"Object should be of type %@.",NSStringFromClass(class));


#endif
