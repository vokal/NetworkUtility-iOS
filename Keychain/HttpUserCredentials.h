//
//  ARUserCredentials.h
//  AirRun
//
//  Created by Anthony Alesia on 10/26/10.
//  Copyright 2010 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABModelInformation

- (NSDictionary *)modelFields;

@end

@interface HttpUserCredentials : NSObject <NSCoding, ABModelInformation> {
    NSString *username;
    NSString *password;
}

@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *password;

+ (void)setCurrentUser:(HttpUserCredentials *)user;
+ (HttpUserCredentials *)getCurrentUser;
+ (void)signOutCurrentUser;

@end
