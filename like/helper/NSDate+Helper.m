//
//  NSDate+Helper.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

@end
