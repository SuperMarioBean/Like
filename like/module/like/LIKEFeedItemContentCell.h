//
//  LIKEFeedItemContentCell.h
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LIKETrendCollectionViewCellTagDataSource <NSObject>

- (NSUInteger)countOfItems;

- (CGSize)imageSizeForIndex:(NSUInteger)index;

- (NSURL *)imageURLForIndex:(NSUInteger)index;

@end

@interface LIKEFeedItemContentCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (readwrite, nonatomic, weak) id <LIKETrendCollectionViewCellTagDataSource> datasource;

@end
