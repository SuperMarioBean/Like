//
//  LIKEThreadItemConversationCell.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEThreadItemConversationCell.h"

@interface LIKEThreadItemConversationCell ()

@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;

@end

@implementation LIKEThreadItemConversationCell

#pragma mark - life cycle

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (![self.unreadCountLabel isHidden]) {
        self.unreadCountLabel.backgroundColor = [UIColor redColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![self.unreadCountLabel isHidden]) {
        self.unreadCountLabel.backgroundColor = [UIColor redColor];
    }
}
#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

- (void)setUnreadCount:(NSUInteger)unreadCount {
    if (unreadCount > 0) {
        if (unreadCount < 9) {
            self.unreadCountLabel.font = [UIFont systemFontOfSize:13];
        }else if(unreadCount > 9 && unreadCount < 99){
            self.unreadCountLabel.font = [UIFont systemFontOfSize:12];
        }else{
            self.unreadCountLabel.font = [UIFont systemFontOfSize:10];
        }
        [self.unreadCountLabel setHidden:NO];
        [self.contentView bringSubviewToFront:self.unreadCountLabel];
        self.unreadCountLabel.text = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    }else{
        [self.unreadCountLabel setHidden:YES];
    }
}

#pragma mark - api methods




@end
