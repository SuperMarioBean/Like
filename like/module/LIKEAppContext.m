//
//  LIKEAppContext.m
//  like
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEAppContext.h"

@implementation LIKEAppContext
#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _localTagsArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

- (BOOL)isReachable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - api methods

+ (instancetype)sharedInstance {
    static LIKEAppContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LIKEAppContext alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

@end
