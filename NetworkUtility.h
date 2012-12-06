//
//  NetworkUtility.h
//  AisleBuyer-iPad
//
//  Created by John Forester on 12/27/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseData : NSObject 

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSHTTPURLResponse *response;

@end

@protocol AbstractNetworkUtilityDelegate
    - (ResponseData *)get:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
    - (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
    - (ResponseData *)put:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
    - (ResponseData *)delete:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;

@optional
    - (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params filePath:(NSString *)filePath authenticate:(BOOL)authenticate error:(NSError *)error;
    - (ResponseData *)postMultiPartFormData:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
    - (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params image:(UIImage*)image withName:(NSString*)name authenticate:(BOOL)authenticate error:(NSError *)error;
@end

@interface NetworkUtility : NSObject
{
}

@property(strong) id<AbstractNetworkUtilityDelegate> delegate;

+ (NetworkUtility *)getInstance;

- (ResponseData *)get:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)put:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)delete:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params filePath:(NSString *)filePath authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)postMultiPartFormData:(NSString *)url withParameters:(NSDictionary *)params authenticate:(BOOL)authenticate error:(NSError *)error;
- (ResponseData *)post:(NSString *)url withParameters:(NSDictionary *)params image:(UIImage*)image withName:(NSString*)name authenticate:(BOOL)authenticate error:(NSError *)error;

@end