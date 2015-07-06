//
//  NSString+Helper.h
//  like
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (CGRect)sizetWithFont:(UIFont *)font constrainedToWide:(CGFloat)wide;

- (BOOL)isNilOrEmpty;

@end
