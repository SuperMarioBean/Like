//
//  UIView+Helper.m
//  like
//
//  Created by David Fu on 6/9/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setTransFrame:(CGRect)frame {
    frame.size.width -= frame.origin.x;
    frame.size.height -= frame.origin.y;
}

@end
