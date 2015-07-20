//
//  LIKEThreadsViewController.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEThreadsViewController.h"

#import "LIKEThreadsViewModel.h"

#import "LIKEThreadItemConversationCell.h"
#import "LIKEChatViewController.h"

@interface LIKEThreadsViewController () <UITabBarDelegate,
                                         EMChatManagerDelegate,
                                         SSPullToRefreshViewDelegate> {
    NSIndexPath *_selectedIndexPath;
    LIKEThreadItemElementKind _kind;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (readwrite, nonatomic, strong) LIKEThreadsViewModel *viewModel;

@property (readwrite, nonatomic, strong) UIView *networkStateView;

@property (readwrite, nonatomic, strong) SSPullToRefreshView *refreshView;

@end

@implementation LIKEThreadsViewController

#pragma mark - life cycle

// TODO: network status changed unhandle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    [self removeEmptyConversationsFromDB];
    
    self.viewModel = [[LIKEThreadsViewModel alloc] init];
    self.tableView.dataSource = self.viewModel;
    self.tableView.tag = LIKEThreadItemElementKindConversation;
    [self.tableView registerNib:[UINib nibWithNibName:@"LIKEThreadItemConversationCell" bundle:nil]
         forCellReuseIdentifier:LIKEThreadItemConversationCellIdentifier];
    
//    self.searchDisplayController.searchResultsDataSource = self.viewModel;
//    self.searchDisplayController.searchResultsTableView.tag = LIKEThreadItemElementKindConversationSearchResult;
//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"LIKEThreadItemConversationCell" bundle:nil]
//                                              forCellReuseIdentifier:LIKEThreadItemConversationSearchResultCellIdentifier];
//    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshDataSource];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [self setupUntreatedApplyCount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame) , 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    [self refreshView];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"threadsToChatSegue"]) {
        EMConversation *conversation = [self.viewModel objectForIndexPath:_selectedIndexPath kind:_kind];
        NSString *chatter = [self chatterForConversation:conversation];
        LIKEChatViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.type = conversation.conversationType;
        destinationViewController.chatter = chatter;
    }
}

#pragma mark - delegate methods

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation:
        case LIKEThreadItemElementKindConversationSearchResult: {
            return 60.0f;
        }
            break;
        default:
            return 0;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    _kind = tableView.tag;
    _selectedIndexPath = indexPath;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"threadsToChatSegue" sender:self];
    });
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
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
                [self.viewModel removeObjectForIndexPath:indexPath kind:LIKEThreadItemElementKindConversation];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
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

#pragma mark IChatMangerDelegate

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState {
    if (connectionState == eEMConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
}

-(void)didUnreadMessagesCountChanged {
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error {
    [self refreshDataSource];
}

- (void)willReceiveOfflineMessages {
    NSLog(NSLocalizedStringFromTable(@"message.beginReceiveOffine", @"chat", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    [self refreshDataSource];
}

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message {
    [self setupUntreatedApplyCount];
}

- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error {
    [self setupUntreatedApplyCount];
}


#pragma mark SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    [self refreshDataSource];
    [view finishLoading];
}

#pragma mark - event response

- (IBAction)threadsUnwind:(UIStoryboardSegue *)sender {
    
}

- (void)handleRefresh:(UIRefreshControl *)sender {
    [self refreshDataSource];
    [sender endRefreshing];
}

#pragma mark - private methods

- (void)setupUntreatedApplyCount {
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (self) {
        if (unreadCount > 0) {
            self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            self.navigationItem.leftBarButtonItem.badgeValue = nil;
        }
    }
}


-(void)refreshDataSource {
    [self.viewModel reloadData];
    [self.tableView reloadData];
}

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

- (void)removeEmptyConversationsFromDB {
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

#pragma mark - accessor methods

- (SSPullToRefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    }
    return _refreshView;
}

- (UIView *)networkStateView {
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedStringFromTable(@"network.disconnection", @"chat", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - api methods

@end
