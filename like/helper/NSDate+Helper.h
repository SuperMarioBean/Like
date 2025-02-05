//
//  NSDate+Helper.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSString *)formattedTime;

- (NSString *)formattedDateDescription;

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;

+ (NSDate *)dateWithTimeIntervalStringInMilliSecondSince1970:(NSString *)timeIntervalStringInMilliSecond;

- (NSString *)timeIntervalStringInMilliSecond;

@end
