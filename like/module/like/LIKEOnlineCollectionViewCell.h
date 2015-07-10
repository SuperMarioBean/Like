//
//  LIKEOnlineCollectionViewCell.h
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LIKEOnlineWidgetType) {
    LIKEOnlineWidgetTypeNone = 0,
    LIKEOnlineWidgetTypeVerify = 1 << 0,
    LIKEOnlineWidgetTypeHot = 1<< 1,
};

@interface LIKEOnlineCollectionViewCell : UICollectionViewCell

@property (readwrite, nonatomic, assign) LIKEOnlineWidgetType type;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (weak, nonatomic) IBOutlet UILabel *sayingLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
