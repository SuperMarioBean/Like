//
//  UICollectionView+Helper.h
//  like
//
//  Created by David Fu on 6/9/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Helper)

- (void)setCurrentIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)currentIndexPath;

@end
