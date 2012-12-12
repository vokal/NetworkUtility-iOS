//
//  NetworkUtilityTest.m
//  EdVOCAL
//
//  Created by Charles Bedrosian on 11/30/12.
//  Copyright (c) 2012 VOKAL Interactive, LLC. All rights reserved.
//

#import "NetworkUtilityTest.h"
#import "RemoteNetworkUtility.h"

@implementation NetworkUtilityTest

- (void)testSetRequestParametersWithUrlEncoding
{
    RemoteNetworkUtility *rnu = [[RemoteNetworkUtility alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSDictionary *data = @{
    @"awards" : @"Mensa",
    @"country": @"Albania",
    @"email": @"null@null.com",
    @"experience" : @"42",
    @"first_name" : @"Test",
    @"language" : @"en",
    @"last_name" : @"User",
    @"state" : @" ",
    @"twitter" : @"tweethandle",
    @"websites" :@" "
    };
    
    [rnu setPostBodyEncodingMethod:UrlEncoding];
    
    [rnu setRequestParameters:data forRequest:request];
    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding];
    
    STAssertTrue([body isEqual:@"twitter=tweethandle&first_name=Test&experience=42&awards=Mensa&last_name=User&email=null%40null.com&country=Albania&state=%20&language=en&websites=%20"], @"body not properly encoded");
}


@end
