//
//  LIKEFilterCollectionViewCell.h
//  like
//
//  Created by David Fu on 7/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCImageView.h"

@interface LIKEFilterCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;

@end
