//
//  UICollectionView+Helper.m
//  like
//
//  Created by David Fu on 6/9/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "UICollectionView+Helper.h"

#import <objc/runtime.h>

static char const LIKEIndexPathKey;

@implementation UICollectionView (Helper)

- (void)setCurrentIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, &LIKEIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)currentIndexPath {
    NSInteger index = self.contentOffset.x / self.frame.size.width;
    
    NSIndexPath *indexPath = objc_getAssociatedObject(self, &LIKEIndexPathKey);
    if (index > 0) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    } else if (indexPath) {
        return indexPath;
    } else {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

@end
