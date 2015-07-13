//
//  LIKEFeedItemUploadCell.h
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LIKEFeedItemUploadStatus) {
    LIKEFeedItemUploadStatusInit,
    LIKEFeedItemUploadStatusSending,
    LIKEFeedItemUploadStatusSent,
    LIKEFeedItemUploadStatusFailed,
};

@interface LIKEFeedItemUploadCell : UICollectionViewCell

@property (readwrite, nonatomic, assign) LIKEFeedItemUploadStatus status;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;

@end
