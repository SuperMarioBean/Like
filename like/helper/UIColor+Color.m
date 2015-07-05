//
//  UIColor+Color.m
//  xiaomuren
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "UIColor+Color.h"

@implementation UIColor (Color)

+ (UIColor *)lw_backgroundColor {
    return [UIColor colorWithHexString:@"E0E0E0"];
}

+ (UIColor *)lw_titleTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)lw_decriptionTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)shirotsurubamiColor {
    return [UIColor colorWithRed:220.0f/255.0f green:184.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
}

+ (UIColor *)shironeriColor {
    return [UIColor colorWithRed:252.0f/255.0f green:250.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
}

+ (UIColor *)byakurokuColor {
    return [UIColor colorWithRed:168.0f/255.0f green:216.0f/255.0f blue:185.0f/255.0f alpha:1.0f];
}

+ (UIColor *)terigakiColor {
    return [UIColor colorWithRed:169.0f/255.0f green:98.0f/255.0f blue:67.0f/255.0f alpha:1.0f];
}

@end
