//
//  LIKEInstanceMessageManager.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEInstanceMessageManager.h"

NSString *const LIKEApplyTitle = @"title";
NSString *const LIKEApplyUsername = @"username";
NSString *const LIKEApplyGroupName = @"groupName";
NSString *const LIKEApplyGroupID = @"groupID";
NSString *const LIKEApplyMessage = @"applyMessage";
NSString *const LIKEApplyStyle = @"applyStyle";

@interface LIKEInstanceMessageManager ()


@end

@implementation LIKEInstanceMessageManager

#pragma mark - life cycle

#pragma mark - delegate methods

#pragma mark - IChatManagerDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

- (NSArray *)conversationsArray {
    return [[EaseMob sharedInstance].chatManager conversations];
}

#pragma mark - api methods

@end
