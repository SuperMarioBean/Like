//
//  LWAppContext.m
//  xiaomuren
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "LWAppContext.h"

@implementation LWAppContext
#pragma mark - life cycle

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
    static LWAppContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LWAppContext alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

@end
