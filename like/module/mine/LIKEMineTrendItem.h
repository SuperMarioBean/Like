//
//  LIKEMineTrendItem.h
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LIKEMineTrendItem : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *trendsCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *latestTrendImageView;

@property (weak, nonatomic) IBOutlet UILabel *latestTrendSortLabel;

@property (weak, nonatomic) IBOutlet UILabel *latestDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *latestTimeLabel;

@end
