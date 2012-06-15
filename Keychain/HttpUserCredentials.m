//
//  ARUserCredentials.m
//  AirRun
//
//  Created by Anthony Alesia on 10/26/10.
//  Copyright 2010 VOKAL. All rights reserved.
//

#import "HttpUserCredentials.h"
#import "SFHFKeychainUtils.h"

#define AR_KEYCHAIN_SERVICE_USER    @"DTKeychain"
#define AR_USER_FILENAME            @"DTKeychain"
#define AR_USER_KEY                 @"DTKeychain"

@implementation HttpUserCredentials

@synthesize username;
@synthesize password;

- (id)init {
	if (self = [super init]) {
		
	}
	
	return self;
}


#pragma mark -
#pragma mark Login Methods
+ (void)setCurrentUser: (HttpUserCredentials *)user {
    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:user.username 
                         andPassword:user.password
                      forServiceName:AR_KEYCHAIN_SERVICE_USER 
                      updateExisting:YES 
                               error:&error];
    
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
	NSString *filePath = [libraryDirectory stringByAppendingPathComponent:AR_USER_FILENAME];
	
	NSMutableData *userData = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:userData];
	[archiver encodeObject:user forKey:AR_USER_KEY];
	[archiver finishEncoding];
	[userData writeToFile:filePath atomically:YES];
}

+ (id)getCurrentUser {
	NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
	NSString *filePath = [libraryDirectory stringByAppendingPathComponent:AR_USER_FILENAME];
    
	NSData *userData = [[NSData alloc] initWithContentsOfFile:filePath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:userData];
	//TODO: this looks like a leak of userData & unarchiver... ~wfleming
	
    HttpUserCredentials *user = [unarchiver decodeObjectForKey:AR_USER_KEY];
	
	NSError *error = nil;
	user.password = [SFHFKeychainUtils getPasswordForUsername:user.username
                                               andServiceName:AR_KEYCHAIN_SERVICE_USER
                                                        error:&error];
	return user;
}

+ (void)signOutCurrentUser {
	NSError *error = nil;
	[SFHFKeychainUtils deleteItemForUsername:[[HttpUserCredentials getCurrentUser] username]
							  andServiceName:AR_KEYCHAIN_SERVICE_USER
									   error:&error];
	NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
	NSString *filePath = [libraryDirectory stringByAppendingPathComponent:AR_USER_FILENAME];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:filePath error:NULL];
}

#pragma mark -
#pragma mark NSCoding Methods

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.username = [decoder decodeObjectForKey:@"username"];
		self.password = [decoder decodeObjectForKey:@"password"];
	}
	
	return self;
}

#pragma mark -
#pragma mark SOKModelInformation Methods

- (NSDictionary *)modelFields {
	return nil;	
}

@end
