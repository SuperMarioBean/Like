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

@interface LIKEThreadsViewController () <EMChatManagerDelegate> {
    NSIndexPath *_selectedIndexPath;
    LIKEThreadItemElementKind _kind;
}

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (readwrite, nonatomic, strong) LIKEThreadsViewModel *viewModel;

@property (readwrite, nonatomic, strong) UIView *networkStateView;

@end

@implementation LIKEThreadsViewController

#pragma mark - life cycle

// TODO: network status changed unhandle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    [self removeEmptyConversationsFromDB];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
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
//  self.searchDisplayController.
    
    [self showHUDWithMessage:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    [self.viewModel.instanceMessageManager loginWithCompletion:^(NSError *error) {
        [self hideHUD];
        if (!error) {
            [self.tableView reloadData];
        }
        else {
            UIAlertView *alertView;
            switch (error.code) {
                case LIKEIMErrorCodeServerNotReachable: {
                    alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                               message:NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!")
                                                            buttonType:UIAlertButtonOk];
                }
                    break;
                case LIKEIMErrorCodeServerAuthenticationFailure: {
                    alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                               message:NSLocalizedString(@"error.AuthenticationFail", @"Connect to the server failed!")
                                                            buttonType:UIAlertButtonOk];
                }
                    break;
                case LIKEIMErrorCodeServerTimeout: {
                    alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                               message:NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!")
                                                            buttonType:UIAlertButtonOk];
                }
                    break;
                default: {
                    alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                               message:NSLocalizedString(@"login.fail", @"Logon failure")
                                                            buttonType:UIAlertButtonOk];
                }
                    break;
            }
            [alertView show];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
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
    if ([identifier isEqualToString:@"chatSegue"]) {
        id conversation = [self.viewModel objectForIndexPath:_selectedIndexPath kind:_kind];
        UIViewController <LIKEThreadsViewControllerProtocol> *destinationViewController = segue.destinationViewController;
        destinationViewController.delegate = self;
        destinationViewController.conversation = conversation;
    }
}

#pragma mark - delegate methods

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (tableView.tag) {
        case LIKEThreadItemElementKindConversation:
        case LIKEThreadItemElementKindConversationSearchResult: {
            return 60;
        }
            break;
        default:
            return 0;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.searchDisplayController setActive:NO animated:YES];
    _kind = tableView.tag;
    _selectedIndexPath = indexPath;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"chatSegue" sender:self];
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

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged {
    [self.tableView reloadData];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error {
    [self.tableView reloadData];
}

- (void)willReceiveOfflineMessages {
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    [self.tableView reloadData];
}

- (void)didFinishedReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
}

#pragma mark - event response

- (void)handleRefresh:(UIRefreshControl *)sender {
    [self.tableView reloadData];
    [sender endRefreshing];
}

#pragma mark - private methods

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
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - api methods

@end
