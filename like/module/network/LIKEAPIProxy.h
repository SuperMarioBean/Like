//
//  LIKEAPIProxy.h
//  like
//
//  Created by David Fu on 6/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger LIKEAPIProxyInvalidRequestID;

@interface LIKEAPIProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callRestfulPOSTWithParams:(NSDictionary *)params
                          resourceName:(NSString *)resourceName
                            completion:(void (^)(NSError *error, id JSON, NSInteger requestID))completion;

- (NSInteger)callRestfulGETWithParams:(NSDictionary *)params
                         resourceName:(NSString *)resourceName
                           completion:(void (^)(NSError *error, id JSON, NSInteger requestID))completion;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
