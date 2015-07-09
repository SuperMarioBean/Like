//
//  LIKETrendCollectionViewHeader.h
//  like
//
//  Created by David Fu on 7/9/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LIKETrendCollectionViewHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderAndAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timelineLabel;

@end
