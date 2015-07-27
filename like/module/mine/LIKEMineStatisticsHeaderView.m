//
//  LIKEMineStatisticsHeaderView.m
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMineStatisticsHeaderView.h"

@implementation LIKEMineStatisticsHeaderView

- (void)awakeFromNib {
    // Initialization code
    self.photosButton.layer.borderWidth = 1.0f;
    self.photosButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.wantsButton.layer.borderWidth = 1.0f;
    self.wantsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.dinnersButton.layer.borderWidth = 1.0f;
    self.dinnersButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.questionsButton.layer.borderWidth = 1.0f;
    self.questionsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;

    UILabel *photosLabel = [[UILabel alloc] init];
    photosLabel.font = [UIFont systemFontOfSize:10.0f];
    photosLabel.textColor = [UIColor like_tintColor];
    photosLabel.text = @"照片";
    [self.photosButton addSubview:photosLabel];
    [photosLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(photosLabel.superview).centerOffset(CGPointMake(0, 15));
    }];
    
    UILabel *wantsLabel = [[UILabel alloc] init];
    wantsLabel.font = [UIFont systemFontOfSize:10.0f];
    wantsLabel.textColor = [UIColor like_tintColor];
    wantsLabel.text = @"想要";
    [self.wantsButton addSubview:wantsLabel];
    [wantsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(wantsLabel.superview).centerOffset(CGPointMake(0, 15));
    }];

    UILabel *dinnersLabel = [[UILabel alloc] init];
    dinnersLabel.font = [UIFont systemFontOfSize:10.0f];
    dinnersLabel.textColor = [UIColor like_tintColor];
    dinnersLabel.text = @"饭局";
    [self.dinnersButton addSubview:dinnersLabel];
    [dinnersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(dinnersLabel.superview).centerOffset(CGPointMake(0, 15));
    }];

    UILabel *questionsLabel = [[UILabel alloc] init];
    questionsLabel.font = [UIFont systemFontOfSize:10.0f];
    questionsLabel.textColor = [UIColor like_tintColor];
    questionsLabel.text = @"问问";
    [self.questionsButton addSubview:questionsLabel];
    [questionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(questionsLabel.superview).centerOffset(CGPointMake(0, 15));
    }];

}

@end
