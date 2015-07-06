//
//  UINavigationBar+Helper.m
//  like
//
//  Created by David Fu on 6/9/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "UINavigationBar+Helper.h"
#import <objc/runtime.h>

@implementation UINavigationBar (Helper)
static char overlayKey;
static char emptyImageKey;

- (UIView *)overlay {
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setOverlay:(UIView *)overlay {
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)emptyImage {
    return objc_getAssociatedObject(self, &emptyImageKey);
}

- (void)setEmptyImage:(UIImage *)image {
    objc_setAssociatedObject(self, &emptyImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)like_setBackgroundColor:(UIColor *)backgroundColor {
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 64)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}

- (void)like_setTranslationY:(CGFloat)translationY {
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)like_setContentAlpha:(CGFloat)alpha {
    if (!self.overlay) {
        [self like_setBackgroundColor:self.barTintColor];
    }
    [self setAlpha:alpha forSubviewsOfView:self];
    if (alpha == 1) {
        if (!self.emptyImage) {
            self.emptyImage = [UIImage new];
        }
        self.backIndicatorImage = self.emptyImage;
    }
}

- (void)setAlpha:(CGFloat)alpha forSubviewsOfView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if (subview == self.overlay) {
            continue;
        }
        subview.alpha = alpha;
        [self setAlpha:alpha forSubviewsOfView:subview];
    }
}

- (void)like_reset {
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:nil];
    
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}

@end
