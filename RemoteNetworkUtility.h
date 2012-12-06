//
//  URLRequest.h
//  URLRequest
//
//  Created by Anthony Alesia on 9/28/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetworkUtility.h"

#define URL_ERROR               @"Error"
#define URL_ERROR_CODE          @"9001"
#define URL_ERROR_CONNECTION    @"No internet connection is available. Please check your network settings and try again."
#define NETWORK_OFFLINE         @"network_offline"
#define NETWORK_ONLINE          @"network_online"

typedef enum {
    RemoteNetworkUtilityAcceptsJSON,
    RemoteNetworkUtilityAcceptsXML,
    RemoteNetworkUtilityAcceptsYAML,
} RemoteNetworkUtilityAcceptsHeader;

@interface RemoteNetworkUtility : NSObject <AbstractNetworkUtilityDelegate> 

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic) RemoteNetworkUtilityAcceptsHeader header;

- (id)initWithAcceptsHeader:(RemoteNetworkUtilityAcceptsHeader)header;

- (NSMutableURLRequest *)createRequest:(NSString *)url;
- (ResponseData *)makeRequest:(NSMutableURLRequest *)request authenticate:(BOOL)authenticate withError:(NSError *)error;

- (void)setAcceptsHeader:(NSMutableURLRequest *)request;
- (void)setRequestParameters:(NSDictionary *)params forRequest:(NSMutableURLRequest *)request;
- (void)setAuthenticationForRequest:(NSMutableURLRequest *)request;

+ (NSString *)postdataForParams:(NSDictionary *)params;
+ (NSString *)getStringForParameters:(NSDictionary *)params;
+ (NSString *)urlEncodedString:(NSString *)string;
+ (NSString *)urlDecodeString:(NSString *)string;

int base64encode(unsigned s_len, char *src, unsigned d_len, char *dst);

@end
