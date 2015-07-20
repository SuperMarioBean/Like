//
//  LIKEChatViewModel.m
//  like
//
//  Created by David Fu on 7/19/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEChatViewModel.h"

@interface LIKEChatViewModel ()

@property (readwrite, nonatomic, strong) EMConversation *conversation;

@end

@implementation LIKEChatViewModel

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithConversation:(EMConversation *) conversation{
    self = [super init];
    if (self) {
        _conversation = conversation;
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark UITableViewDataSource

#pragma mark - event response

#pragma mark - private methods


#pragma mark - accessor methods

#pragma mark - api methods

@end
