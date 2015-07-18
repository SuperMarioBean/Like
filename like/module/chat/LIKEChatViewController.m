//
//  LIKEChatViewController.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEChatViewController.h"

@interface LIKEChatViewController ()

@end

@implementation LIKEChatViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self chatterForConversation:self.conversation];
    [self.conversation markAllMessagesAsRead:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

- (NSString *)chatterForConversation:(EMConversation *)conversation {
    
    NSString *title = conversation.chatter;
    if (conversation.conversationType != eConversationTypeChat) {
        if ([[conversation.ext objectForKey:@"groupSubject"] length]) {
            title = [conversation.ext objectForKey:@"groupSubject"];
        }
        else {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    title = group.groupSubject;
                    break;
                }
            }
        }
    }
    // TODO: some robot thing
    return title;
}

#pragma mark - accessor methods

#pragma mark - api methods

@end
