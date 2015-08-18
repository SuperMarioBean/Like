//
//  LIKEAppContext.h
//  like
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIKEUser.h"

typedef NS_ENUM(NSInteger, eLIKEApplyStyle) {
    eLIKEApplyStyleFriend = 0,
    eLIKEApplyStyleGroupInvitation,
    eLIKEApplyStyleJoinGroup,
};

@interface LIKEAppContext :NSObject  <EMChatManagerDelegate>

@property (readonly, getter=isReachable, nonatomic, assign) BOOL reachable;

@property (readwrite, nonatomic, strong) NSMutableArray *localTagsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testTrendsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testUploadTrendsArray;

@property (readwrite, nonatomic, copy) NSString *username;

@property (readwrite, nonatomic, copy) NSString *password;

@property (readwrite, nonatomic, assign) BOOL isAutoLogin;

@property (readwrite, nonatomic, assign) BOOL hasWelcomeNewUser;

+ (instancetype)sharedInstance;

@end
