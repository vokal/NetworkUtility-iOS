//
//  NetworkUtility.m
//  AisleBuyer-iPad
//
//  Created by John Forester on 12/27/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import "NetworkUtility.h"

@implementation NetworkUtility

@synthesize delegate;

#pragma mark - 

static NetworkUtility *_instance = nil;

+ (NetworkUtility *)getInstance
{    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
    });
        
    return _instance;
}

- (ResponseData *)get:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate get:url withParameters:params authenticate:authenticate error:error];
}

- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate post:url withParameters:params authenticate:authenticate error:error];
}

- (ResponseData *)put:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate put:url withParameters:params authenticate:authenticate error:error];
}

- (ResponseData *)delete:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate delete:url withParameters:params authenticate:authenticate error:error];
}

- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params filePath:(NSString *)filePath authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate post:url withParameters:params filePath:filePath authenticate:authenticate error:error];
}

- (ResponseData *)postMultiPartFormData:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error
{
    return [self.delegate postMultiPartFormData:url withParameters:params  authenticate:authenticate error:error];
}

- (void)setPostBodyEncodingMethod:(PostBodyEncodingMethod)method
{
    [self.delegate setPostBodyEncodingMethod:method];
}


@end

@implementation ResponseData

@synthesize data;
@synthesize response;

@end