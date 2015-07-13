//
//  LIKEFeedItemUploadCell.m
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEFeedItemUploadCell.h"

@interface LIKEFeedItemUploadCell ()

@property (weak, nonatomic) IBOutlet UILabel *uploadStatusLabel;

@end

@implementation LIKEFeedItemUploadCell

#pragma mark - life cycle

- (void)awakeFromNib {
    self.status = LIKEFeedItemUploadStatusInit;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

- (void)setStatus:(LIKEFeedItemUploadStatus)status {
    switch (status) {
        case LIKEFeedItemUploadStatusInit: {
            
        }
            break;
        case LIKEFeedItemUploadStatusSending: {
            self.refreshButton.hidden = YES;
            self.uploadStatusLabel.text = @"发送中...";
        }
            break;
        case LIKEFeedItemUploadStatusSent: {
            self.uploadStatusLabel.text = @"已发送";
        }
            break;
        case LIKEFeedItemUploadStatusFailed: {
            self.refreshButton.hidden = NO;
            self.uploadStatusLabel.text = @"失败";
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - api methods

@end
