//
//  URLRequest.m
//  URLRequest
//
//  Created by Anthony Alesia on 9/28/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import "RemoteNetworkUtility.h"
#import "HttpUserCredentials.h"

#define DEBUG_MODE  1
#define TIMEOUT     30.0

@interface RemoteNetworkUtility ()
{
    int _numberOfRequests;
}

@property PostBodyEncodingMethod encodingMethod;

@end

@implementation RemoteNetworkUtility

@synthesize connection;
@synthesize header;

- (id)initWithAcceptsHeader:(RemoteNetworkUtilityAcceptsHeader)accepts
{
    return [self initWithAcceptsHeader:accepts postBodyEncoding:JsonEncoding];
}

- (id)initWithAcceptsHeader:(RemoteNetworkUtilityAcceptsHeader)accepts postBodyEncoding:(PostBodyEncodingMethod)encoding
{
    self.header = accepts;
    self.postBodyEncodingMethod = encoding;
    
    return self;
}

#pragma mark AbstractNetworkUtilityDelegate

- (ResponseData *)get:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{    
    if (params != nil) {
        url = [NSString stringWithFormat:@"%@?%@", url, [RemoteNetworkUtility getStringForParameters:params]];
    }
#if DEBUG    
    NSLog(@"Making request [GET]: %@",url);
#endif    
    NSMutableURLRequest *request = [self createRequest:url];
    
    [request setHTTPMethod:@"GET"];
    
    return [self makeRequest:request authenticate:authenticate withError:error];
}

- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
#if DEBUG    
    NSLog(@"Making request [POST]: %@ params: %@",url,params);
#endif    
    NSMutableURLRequest *request = [self createRequest:url];
    if (params != nil) {
        [self setRequestParameters:params
                        forRequest:request];
    }
    [request setHTTPMethod:@"POST"];
    return [self makeRequest:request authenticate:authenticate withError:error];
}

- (ResponseData *)put:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
#if DEBUG    
    NSLog(@"Making request [PUT]: %@ params: %@",url,params);
#endif    
    NSMutableURLRequest *request = [self createRequest:url];
    
    [self setRequestParameters:params
                    forRequest:request];
    [request setHTTPMethod:@"PUT"];
    
    return [self makeRequest:request authenticate:authenticate withError:error];
}

- (ResponseData *)delete:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
#if DEBUG    
    NSLog(@"Making request [DELETE]: %@ params: %@",url,params);
#endif    
    NSMutableURLRequest *request = [self createRequest:url];
    
    [self setRequestParameters:params
                    forRequest:request];
    [request setHTTPMethod:@"DELETE"];
    
    return [self makeRequest:request authenticate:authenticate withError:error];
}

# pragma mark RemoteNetworkUtility methods

- (NSMutableURLRequest *)createRequest:(NSString *)url 
{
    NSURL *requestUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPShouldHandleCookies:NO];
    
    return request;
}

- (ResponseData *)makeRequest:(NSMutableURLRequest *)request authenticate:(BOOL)authenticate withError:(NSError *)error
{
    _numberOfRequests++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self setAcceptsHeader:request];
    
    if (authenticate) {
        [self setAuthenticationForRequest:request];
    }
    
    connection = [[NSURLConnection alloc] init];
    
    if (connection == nil) {
        _numberOfRequests--;
        
        if (_numberOfRequests == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No connection" forKey:NSLocalizedDescriptionKey];
        
        error = [NSError errorWithDomain:@"remoteNetworkUtility" code:100 userInfo:errorDetails];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_OFFLINE
                                                            object:nil];
    } else {
        @try {
            ResponseData *responseData = [[ResponseData alloc]init];
            
            NSHTTPURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            responseData.data = data;
            responseData.response = response;
            
            NSLog(@"RESPONSE CODE: %d",response.statusCode);
            
            if (response.statusCode == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_OFFLINE
                                                                    object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_ONLINE
                                                                    object:nil];
            }
            
            return responseData;
        } @finally {
            _numberOfRequests--;
            
            if (_numberOfRequests == 0) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }
    
    return nil;
}

- (void)setAcceptsHeader:(NSMutableURLRequest *)request 
{
    switch (self.header) {
        case RemoteNetworkUtilityAcceptsXML:
            [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
            break;
        case RemoteNetworkUtilityAcceptsYAML:
            [request setValue:@"application/yaml" forHTTPHeaderField:@"Accept"];
            break;
        case RemoteNetworkUtilityAcceptsJSON:
        default:
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            break;
    }
}

- (void)setRequestParameters:(NSDictionary *)params forRequest:(NSMutableURLRequest *)request
{
    switch (self.encodingMethod) {
        case JsonEncoding:
            [self setRequestParametersWithJsonEncoding:params forRequest:request];
            break;
        case UrlEncoding :
            [self setRequestParametersWithUrlEncoding:params forRequest:request];
            break;
    }
}

- (void)setRequestParametersWithJsonEncoding:(NSDictionary *)params forRequest:(NSMutableURLRequest *)request
{    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONReadingAllowFragments error:nil];
   
    NSString *requestLength = [NSString stringWithFormat:@"%d", [requestData length]];
    NSLog(@"sending this JSON :::: %@",[[NSString alloc]initWithData:requestData encoding:NSUTF8StringEncoding]);
    [request setValue:requestLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"]; 
    [request setHTTPBody:requestData];
}

- (void)setRequestParametersWithUrlEncoding:(NSDictionary *)params forRequest:(NSMutableURLRequest *)request
{
    NSMutableString *postBody = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *val = [[NSMutableString alloc] init];;
    for (NSString *key in params) {
        id object = [params objectForKey:key];
        if ([object isKindOfClass:[NSArray class]]) {
            [val setString:@""];
            for(id objectFromArray in (NSArray *)object) {
                NSString *stringFromArray = [NSString stringWithFormat:@"%@", objectFromArray];
                if ([postBody length] > 0)
                    [postBody appendFormat:@"&%@=%@", key, [RemoteNetworkUtility urlEncodedString:stringFromArray]];
                else
                    [postBody appendFormat:@"%@=%@", key, [RemoteNetworkUtility urlEncodedString:stringFromArray]];
            }
        }
        else {
            [val setString:[NSString stringWithFormat:@"%@", object]];
            if ([postBody length] > 0)
                [postBody appendFormat:@"&%@=%@", key, [RemoteNetworkUtility urlEncodedString:val]];
            else
                [postBody appendFormat:@"%@=%@", key, [RemoteNetworkUtility urlEncodedString:val]];
        }        
    }
    
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSLog(@"%@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding]);
}

- (void)setAuthenticationForRequest:(NSMutableURLRequest *)request 
{
    HttpUserCredentials *user = [HttpUserCredentials getCurrentUser];
    
    if ([user.username length] == 0) {
        return;
    }
    
    NSMutableString *dataStr = (NSMutableString*)[@"" stringByAppendingFormat:@"%@:%@", user.username, user.password];
    NSData *encodeData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    char encodeArray[512];
    memset(encodeArray, '\0', sizeof(encodeArray));
    base64encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
    NSString *encodedString = [[NSString alloc] initWithBytes:encodeArray length:sizeof(encodeArray) encoding:NSASCIIStringEncoding];
    
    NSString *authenticationString = [@"" stringByAppendingFormat:@"Basic %@", encodedString];
    
    [request addValue:authenticationString forHTTPHeaderField:@"Authorization"];
}

- (void)setPostBodyEncodingMethod:(PostBodyEncodingMethod)method
{
    self.encodingMethod = method;
}

#pragma mark - class methods

+ (NSString *)getStringForParameters:(NSDictionary *)params 
{
    NSMutableString *parameterUrl = [[NSMutableString alloc]init];
    
    for (NSString *key in [params allKeys]) {
        [parameterUrl appendFormat:@"%@=%@", key, [params objectForKey:key]];
        
        if (key != [[params allKeys] lastObject]) {
            [parameterUrl appendFormat:@"&"];
        }
    }
    
    return parameterUrl;
}

+ (NSString *)postdataForParams:(NSDictionary *)params
{
    NSMutableString *parameterUrl = [[NSMutableString alloc]init];
    
    for (NSString *key in [params allKeys]) {
        [parameterUrl appendFormat:@"%@=\"%@\"", key, [params objectForKey:key]];
        
        if (key != [[params allKeys] lastObject]) {
            [parameterUrl appendFormat:@";"];
        }
    }
    
    return parameterUrl;
}

+ (NSString *)urlEncodedString:(NSString *)string 
{
    NSString *escaped = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    escaped = [escaped stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
    return escaped;
}

+ (NSString *)urlDecodeString:(NSString *)string 
{
    NSString *escaped = string;
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%40" withString:@"@"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%09" withString:@"\t"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3C" withString:@"<"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3E" withString:@">"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%22" withString:@"\""];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%0A" withString:@"\n"];
    return escaped;
}

#pragma mark - Base64 encoding

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int base64encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
    unsigned triad;
    
    for (triad = 0; triad < s_len; triad += 3)
    {
        unsigned long int sr = 0;
        unsigned byte;
        
        for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
        {
            sr <<= 8;
            sr |= (*(src+triad+byte) & 0xff);
        }
        
        sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
        
        if (d_len < 4) return 1; /* error - dest too short */
        
        *(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
        switch(byte)
        {
            case 3:
                *(dst+3) = base64[sr&0x3f];
                sr >>= 6;
            case 2:
                *(dst+2) = base64[sr&0x3f];
                sr >>= 6;
            case 1:
                *(dst+1) = base64[sr&0x3f];
                sr >>= 6;
                *(dst+0) = base64[sr&0x3f];
        }
        dst += 4; d_len -= 4;
    }
    
    return 0;
    
}

@end
