//
//  LIKEMainTabBarController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMainTabBarController.h"
#import "LIKEInstanceMessageManager.h"

@interface LIKEMainTabBarController () <UITabBarControllerDelegate,
                                        EMChatManagerDelegate,
                                        EMCallManagerDelegate>

@end

@implementation LIKEMainTabBarController

#pragma mark - life cycle

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.selectedIndex = 1;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reset];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
}

#pragma mark - delegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2) {
        [self performSegueWithIdentifier:@"postSegue" sender:self];
        return NO;
    }
    return YES;
}

- (void)didUpdateConversationList:(NSArray *)conversationList {
    [self setupUnreadMessageCount];
}

// 未读消息数量变化回调
- (void)didUnreadMessagesCountChanged {
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineMessages {
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineCmdMessages {
    
}

// 开始自动登录回调
- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.errorAutoLogin", LIKELocalizeChat, @"Automatic logon failure")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                     otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification object:@NO];
    }
    else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.beginAutoLogin", LIKELocalizeChat, @"Start automatic login...")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                     otherButtonTitles:nil, nil];
    }
    [alertView show];
}

// 结束自动登录回调
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.errorAutoLogin", LIKELocalizeChat, @"Automatic logon failure")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                     otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification object:@NO];
    }
    else{
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
        
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.endAutoLogin", LIKELocalizeChat, @"End automatic login...")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                     otherButtonTitles:nil, nil];
        // 旧数据转换 (如果您的sdk是由2.1.2版本升级过来的，需要家这句话)
        [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
        //获取数据库中的数据
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];

        [self setupUnreadMessageCount];
    }
    
    [alertView show];
}

// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error {
    NSString *tmpStr = group.groupSubject;
    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    if (reason == eGroupLeaveReason_BeRemoved) {
        str = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.beKicked", LIKELocalizeChat, @"you have been kicked out from the group of \'%@\'"), tmpStr];
    }
    if (str.length > 0) {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, nil)
                                                     message:str
                                                  controller:self];
    }
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error {
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.beRefusedToJoin", LIKELocalizeChat, @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                                        message:reason
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}



// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error {
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.agreedAndJoined", LIKELocalizeChat, @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error {
    if (error) {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeChat, nil)
                                                     message:NSLocalizedStringFromTable(@"apns.failToBindDeviceToken", LIKELocalizeChat, @"Fail to bind device token")
                                                  controller:self];
    }
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error {
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.applyJoin", LIKELocalizeChat, @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.applyJoinWithName", LIKELocalizeChat, @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.sendApplyFail", LIKELocalizeChat, @"send application failure:%@\nreason：%@"), reason, error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeChat, @"Error")
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK")
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{LIKEApplyTitle: groupname,
                                                                                   LIKEApplyGroupID: groupId,
                                                                                   LIKEApplyUsername: username,
                                                                                   LIKEApplyGroupName: groupname,
                                                                                   LIKEApplyMessage:reason,
                                                                                   LIKEApplyStyle: @(eLIKEApplyStyleJoinGroup)}];
        [[ApplyViewController shareController] addNewApply:dic];
    }
}

// 好友申请回调
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message {
    if (!username) {
        return;
    }
    if (!message) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"friend.somebodyAddWithName", LIKELocalizeChat,  @"%@ add you as a friend"), username];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{LIKEApplyTitle: username,
                                                                               LIKEApplyUsername: username,
                                                                               LIKEApplyMessage: message,
                                                                               LIKEApplyStyle: @(eLIKEApplyStyleFriend)
                                                                               }];
    [[ApplyViewController shareController] addNewApply:dic];
}

#pragma mark - event response

- (IBAction)mainUnwind:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"publishUnwindSegue"]) {
        self.selectedIndex = 1;
    }
}

#pragma mark - private methods

- (void)reset {
    if (![LIKEUserContext sharedInstance].user) {
        if ([LIKEAppContext sharedInstance].isAutoLogin) {
            NSString *username = [LIKEAppContext sharedInstance].username;
            NSString *password = [LIKEAppContext sharedInstance].password;
            [[LIKEUserContext sharedInstance] loginWithPhoneNumber:username
                                                          password:password
                                                        completion:^(NSError *error) {
                                                            if (!error) {
                                                                NSLog(@"=========登陆成功!!!==========");
                                                                [self setupUnreadMessageCount];
                                                            }
                                                            else {
                                                                NSLog(@"%@", error);
                                                                [self performSegueWithIdentifier:@"accountSegue" sender:self];
                                                            }
                                                        }];
        }
        else {
            [self performSegueWithIdentifier:@"accountSegue" sender:self];
        }
    }
    else {
        // 说明用户登录过, 不需要任何动作
    }
}

- (void)registerNotifications {
    [self unregisterNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:LIKELogoutSuccessNotification object:nil];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

// 统计未读消息数
- (void)setupUnreadMessageCount {
    NSInteger unreadCount = [LIKEUserContext sharedInstance].user.unreadCount;
    if (unreadCount > 0) {
        [[self.tabBar.items firstObject] setBadgeValue:[NSString stringWithFormat:@"%i",(int)unreadCount]];
    }else{
        [[self.tabBar.items firstObject] setBadgeValue:nil];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - accessor methods

#pragma mark - api methods

@end
