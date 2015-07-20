//
//  LIKEUser.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEUser.h"

@implementation LIKEUser

- (instancetype)init {
    return [self initWithPhoneNumber:@"" username:@"" password:@"" male:YES birthday:nil];
}

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           username:(NSString *)username
                           password:(NSString *)password
                               male:(BOOL)male
                           birthday:(NSDate *)birthday {
    self = [super init];
    if (self) {
        _forgetPassword = NO;
        _login = NO;
        _phoneNumber = phoneNumber;
        _username = username;
        _password = password;
        _male = male;
        _birthday = birthday;
        _imUsername = nil;
        _imPassword = nil;
    }
    return self;
}

@end
