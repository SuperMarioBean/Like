//
//  LIKEChatViewController.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LIKEThreadsViewControllerProtocol.h"
#import "LIKEChatViewControllerDelegate.h"

typedef NS_ENUM(NSInteger, LIKEChatViewControllerType) {
    LIKEChatViewControllerTypeChat = 0,
    LIKEChatViewControllerTypeGroupChat,
    LIKEChatViewControllerTypeChatRoom
};

@interface LIKEChatViewController : UIViewController <LIKEThreadsViewControllerProtocol>

@property (readwrite, nonatomic, strong) EMConversation *conversation;

@property (readwrite, nonatomic, weak) id <LIKEChatViewControllerDelegate> delegate;

@end
