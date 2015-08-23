//
//  OBClickRegistrationOperation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBClickRegistrationOperation.h"

@implementation OBClickRegistrationOperation

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self setFinished:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setFinished:YES];
}

@end
