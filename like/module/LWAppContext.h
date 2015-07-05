//
//  LWAppContext.h
//  xiaomuren
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWUser.h"

@interface LWAppContext : NSObject

@property (readonly, nonatomic, strong) LWUser *user;

@property (readonly, getter=isReachable, nonatomic, assign) BOOL reachable;

@property (readwrite, nonatomic, assign) CGFloat width;

@property (readwrite, nonatomic, assign) CGFloat scaledWidth;

+ (instancetype)sharedInstance;

@end
