//
//  LIKEAppContext.h
//  like
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIKEUser.h"

@interface LIKEAppContext : NSObject

@property (readonly, nonatomic, strong) LIKEUser *user;

@property (readonly, getter=isReachable, nonatomic, assign) BOOL reachable;

@property (readwrite, nonatomic, assign) CGFloat width;

@property (readwrite, nonatomic, assign) CGFloat scaledWidth;

@property (readwrite, nonatomic, strong) NSMutableArray *localTagsArray;

+ (instancetype)sharedInstance;

@end
