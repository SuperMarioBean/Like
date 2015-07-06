//
//  NSString+Helper.m
//  like
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (CGRect)sizetWithFont:(UIFont *)font constrainedToWide:(CGFloat)wide {
    if (self) {
        NSDictionary* attributes = @{NSFontAttributeName: font};
        CGRect rect = [self boundingRectWithSize:CGSizeMake(wide, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
        return rect;
    }
    return CGRectZero;
}

- (BOOL)isNilOrEmpty {
    return self && self.length ? NO: YES;
}

@end
