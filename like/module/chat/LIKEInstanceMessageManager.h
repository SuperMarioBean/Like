//
//  LIKEInstanceMessageManager.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEAPIBaseManager.h"

#import "ApplyViewController.h"

extern NSString *const LIKEApplyTitle;
extern NSString *const LIKEApplyUsername;
extern NSString *const LIKEApplyGroupName;
extern NSString *const LIKEApplyGroupID;
extern NSString *const LIKEApplyMessage;
extern NSString *const LIKEApplyStyle;

typedef NS_ENUM(NSInteger, LIKEIMErrorCode) {
    LIKEIMErrorCodeServerNotReachable = EMErrorServerNotReachable,
    LIKEIMErrorCodeServerAuthenticationFailure = EMErrorServerAuthenticationFailure,
    LIKEIMErrorCodeServerTimeout = EMErrorServerTimeout,
};

@interface LIKEInstanceMessageManager : LIKEAPIBaseManager <EMChatManagerDelegate>

@property (readwrite, nonatomic, strong) NSArray *conversationsArray;

@property (readwrite, nonatomic, strong) NSArray *groupsArray;

@end
