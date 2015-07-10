//
//  LIKEOnlineCollectionViewCell.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEOnlineCollectionViewCell.h"

@interface LIKEOnlineCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *hotLabel;

@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;

@property (weak, nonatomic) IBOutlet UIView *maskView;
@end

@implementation LIKEOnlineCollectionViewCell

- (void)awakeFromNib {
}

- (void)setType:(LIKEOnlineWidgetType)type {
    _type = type;
    
    if ((self.type & LIKEOnlineWidgetTypeHot) == LIKEOnlineWidgetTypeHot) {
        self.hotLabel.hidden = NO;
        self.hotLabel.text = @"HOT";
        self.hotLabel.backgroundColor = [UIColor magentaColor];
        if ((self.type & LIKEOnlineWidgetTypeVerify) == LIKEOnlineWidgetTypeVerify) {
            self.verifyLabel.hidden = NO;
            self.verifyLabel.text = @"认证";
            self.verifyLabel.backgroundColor = [UIColor orangeColor];
        }
        else {
            self.verifyLabel.hidden = YES;
        }
    }
    else {
        self.verifyLabel.hidden = YES;
        if ((self.type & LIKEOnlineWidgetTypeVerify) == LIKEOnlineWidgetTypeVerify) {
            self.hotLabel.hidden = NO;
            self.hotLabel.text = @"认证";
            self.hotLabel.backgroundColor = [UIColor orangeColor];
        }
        else {
            self.hotLabel.hidden = YES;
        }
    }
}

@end
