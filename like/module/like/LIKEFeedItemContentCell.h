//
//  LIKEFeedItemContentCell.h
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagView.h"

@interface LIKEFeedItemContentCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)beginTagsUpdate;

- (void)updateTagWithPoint:(CGPoint)point
                     title:(NSString *)title
                      type:(TagType)type
                 direction:(TagDirection)direciton;

- (void)endTagsUpdate;
@end
