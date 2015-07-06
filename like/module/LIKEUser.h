//
//  LIKEUser.h
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIKEUser;
extern LIKEUser *__user;
void initUser();

@interface LIKEUser : NSObject

@property (readwrite, getter=isForgetPassword, nonatomic, assign) BOOL forgetPassword;

@property (readwrite, getter=isLogin, nonatomic, assign) BOOL login;

@property (readwrite, nonatomic, copy) NSString *phoneNumber;

@property (readwrite, nonatomic, copy) NSString *username;

@property (readwrite, nonatomic, copy) NSString *password;

@property (readwrite, getter=isMale, nonatomic, assign) BOOL male;

@property (readwrite, nonatomic, strong) NSDate *birthday;

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           username:(NSString *)username
                           password:(NSString *)password
                               male:(BOOL)male
                           birthday:(NSDate *)birthday;

@end
