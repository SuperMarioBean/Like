//
//  LIKEThreadsViewControllerProtocol.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMConversation;
@protocol LIKEChatViewControllerDelegate;

@protocol LIKEThreadsViewControllerProtocol <NSObject>

- (void)setDelegate:(id <LIKEChatViewControllerDelegate>)delegate;

- (void)setConversation:(EMConversation *)conversation;

@end
