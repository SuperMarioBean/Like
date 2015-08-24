//
//  LIKEThreadsViewModel.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEThreadsViewModel.h"

#import "LIKEThreadItemConversationCell.h"

NSString *const LIKEThreadItemConversationCellIdentifier = @"com.trinity.chat.thread.cell.identifier.conversation";
NSString *const LIKEThreadItemConversationSearchResultCellIdentifier = @"com.trinity.chat.thread.cell.identifier.conversation.searchResult";

@interface LIKEThreadsViewModel ()

@property (readwrite, nonatomic, strong) NSMutableArray *conversations;

@property (readwrite, nonatomic, strong) NSArray *searchResults;

@end

@implementation LIKEThreadsViewModel

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _instanceMessageManager = [[LIKEInstanceMessageManager alloc] init];
    }
    return self;
}

#pragma mark - delegate methods

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation: {
            return self.conversations.count;
        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
            return self.searchResults.count;
        }
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation: {
            cell = [tableView dequeueReusableCellWithIdentifier:LIKEThreadItemConversationCellIdentifier forIndexPath:indexPath];
            [self configureTableView:tableView cell:cell kind:LIKEThreadItemElementKindConversation indexPath:indexPath];
        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
            cell = [tableView dequeueReusableCellWithIdentifier:LIKEThreadItemConversationSearchResultCellIdentifier forIndexPath:indexPath];
            [self configureTableView:tableView cell:cell kind:LIKEThreadItemElementKindConversationSearchResult indexPath:indexPath];
        }
            break;
        default:
            cell = nil;
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation: {
            return YES;
        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
            return NO;
        }
        default:
            return NO;
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation: {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                [self removeObjectForIndexPath:indexPath kind:LIKEThreadItemElementKindConversation];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
        }
        default:
            break;
    }
}

#pragma mark - event response

#pragma mark - private methods

- (NSString *)lastMessageTimeByConversation:(EMConversation *)conversation {
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [[NSDate dateWithTimeIntervalInMilliSecondSince1970:lastMessage.timestamp] timeAgoSimple];
    }
    
    return ret;
}

- (NSUInteger)unreadMessageCountByConversation:(EMConversation *)conversation {
    NSUInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    return  ret;
}

- (NSString *)subTitleMessageByConversation:(EMConversation *)conversation {
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedStringFromTable(@"message.image1", LIKELocalizeChat, @"[image]");
            } break;
            case eMessageBodyType_Text:{
                ret = [[(EMTextMessageBody *)messageBody text] stringByReplacingEmojiCheatCodesWithUnicode];
            }
                break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedStringFromTable(@"message.voice1", LIKELocalizeChat, @"[voice]");
            }
                break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedStringFromTable(@"message.location1", LIKELocalizeChat, @"[location]");
            }
                break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedStringFromTable(@"message.video1", LIKELocalizeChat, @"[video]");
            }
                break;
            default: {
            }
                break;
        }
    }
    
    return ret;
}


#pragma mark - accessor methods

#pragma mark - api methods

- (NSMutableArray *)reloadData {
    NSMutableArray *ret = nil;
    NSArray *conversations = [self.instanceMessageManager conversationsArray];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    self.conversations = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath kind:(LIKEThreadItemElementKind)kind {
    switch (kind) {
        case LIKEThreadItemElementKindConversation: {
            return self.conversations[indexPath.row];
        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
            return self.searchResults[indexPath.row];
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)removeObjectForIndexPath:(NSIndexPath *)indexPath kind:(LIKEThreadItemElementKind)kind {
    switch (kind) {
        case LIKEThreadItemElementKindConversation: {
            EMConversation *conversation = self.conversations[indexPath.row];
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter
                                                               deleteMessages:YES
                                                                  append2Chat:YES];
            [self.conversations removeObjectAtIndex:indexPath.row];

        }
            break;
        case LIKEThreadItemElementKindConversationSearchResult: {
        }
            break;
    }
}

- (void)configureTableView:(UITableView *)tableView
                      cell:(UITableViewCell *)tableViewCell
                      kind:(LIKEThreadItemElementKind)kind
                 indexPath:(NSIndexPath *)indexPath {
    switch (kind) {
        case LIKEThreadItemElementKindConversation:
        case LIKEThreadItemElementKindConversationSearchResult: {
            LIKEThreadItemConversationCell *cell = (LIKEThreadItemConversationCell *)tableViewCell;
            EMConversation *conversation = [self objectForIndexPath:indexPath kind:kind];
            cell.nameLabel.text = conversation.chatter;
            
            switch (conversation.conversationType) {
                case eConversationTypeChat: {
                    //                if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.chatter]) {
                    //                    cell.name = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.chatter];
                    //                }
                    [cell.avatarImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
                }
                    break;
                case eConversationTypeGroupChat: {
                    NSString *imageName = @"groupPublicHeader";
                    if (![conversation.ext objectForKey:@"groupSubject"]
                        || ![conversation.ext objectForKey:@"isPublic"]) {
                        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
                        for (EMGroup *group in groupArray) {
                            if ([group.groupId isEqualToString:conversation.chatter]) {
                                cell.nameLabel.text = group.groupSubject;
                                imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                                
                                NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                                [ext setObject:group.groupSubject forKey:@"groupSubject"];
                                [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                                conversation.ext = ext;
                                break;
                            }
                        }
                    }
                    else {
                        cell.nameLabel.text = [conversation.ext objectForKey:@"groupSubject"];
                        imageName = [[conversation.ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
                    }
                    [cell.avatarImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:imageName]];
                }
                    break;
                case eConversationTypeChatRoom: {
                    
                }
                    break;
                    
                default:
                    break;
            }
            if (conversation.conversationType == eConversationTypeChat) {
            }
            else{
                
            }
            cell.lastestMessagelabel.text = [self subTitleMessageByConversation:conversation];
            cell.timeLabel.text = [self lastMessageTimeByConversation:conversation];
            cell.unreadCount = [self unreadMessageCountByConversation:conversation];
        }
            break;
            
        default:
            break;
    }
}

- (void)searchWithText:(NSString *)text completion:(void (^)(void))completion{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.conversations
                                                    searchText:text
                                       collationStringSelector:@selector(chatter)
                                                   resultBlock:^(NSArray *results) {
                                                       if (results) {
                                                           self.searchResults = results;
                                                       }
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           completion();
                                                       });
                                                   }];
}

@end
