//
//  UIColor+section.m
//  like
//
//  Created by David Fu on 7/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "UIColor+section.h"

@implementation UIColor (section)

+ (UIColor *)like_tintColor {
    return [UIColor ohniColor];
}

+ (UIColor *)like_viewBackgroundColor {
    return [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
}

+ (UIColor *)like_moreViewBackgroundColor {
    return [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
}

+ (UIColor *)like_buttonColor {
    return [UIColor colorWithRed:255.0/255.0 green:163/255.0 blue:13.0/255.0 alpha:1.0];
}

@end
