//
//  LIKEThreadsViewModel.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LIKEThreadItemConversationCell.h"

#import "LIKEInstanceMessageManager.h"

extern NSString *const LIKEThreadItemConversationCellIdentifier;
extern NSString *const LIKEThreadItemConversationSearchResultCellIdentifier;

typedef NS_ENUM(NSInteger, LIKEThreadItemElementKind) {
    LIKEThreadItemElementKindConversation = 0,
    LIKEThreadItemElementKindConversationSearchResult
};

@interface LIKEThreadsViewModel : NSObject <UITableViewDataSource>

@property (readonly, nonatomic, strong) LIKEInstanceMessageManager *instanceMessageManager;

- (NSMutableArray *)reloadData;

- (id)objectForIndexPath:(NSIndexPath *)indexPath kind:(LIKEThreadItemElementKind)kind;

- (void)removeObjectForIndexPath:(NSIndexPath *)indexPath kind:(LIKEThreadItemElementKind)kind;

- (void)searchWithText:(NSString *)text completion:(void (^)(void))completion;

@end
