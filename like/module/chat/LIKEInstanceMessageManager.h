//
//  LIKEInstanceMessageManager.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEAPIBaseManager.h"

typedef NS_ENUM(NSInteger, LIKEIMErrorCode) {
    LIKEIMErrorCodeServerNotReachable = EMErrorServerNotReachable,
    LIKEIMErrorCodeServerAuthenticationFailure = EMErrorServerAuthenticationFailure,
    LIKEIMErrorCodeServerTimeout = EMErrorServerTimeout,
};

extern NSString *const LIKEIMLoginChangeNotification;

@interface LIKEInstanceMessageManager : LIKEAPIBaseManager

@property (readwrite, nonatomic, strong) NSArray *conversationsArray;

@property (readwrite, nonatomic, strong) NSArray *groupsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *appliesArray;

- (void)loginWithCompletion:(void (^)(NSError *error))completion;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *error))completion;

@end
