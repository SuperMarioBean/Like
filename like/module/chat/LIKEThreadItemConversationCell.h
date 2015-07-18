//
//  LIKEThreadItemConversationCell.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LIKEThreadItemConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastestMessagelabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setUnreadCount:(NSUInteger)unreadCount;

@end
