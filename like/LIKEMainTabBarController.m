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
    self.selectedIndex = 1;
    
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LIKEUser *user;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"username"];
    NSString *password = [userDefaults objectForKey:@"password"];
    if (username
        && password
        && [username isEqualToString:password]) {
        user = [LIKEAppContext sharedInstance].user;
        user.phoneNumber = username;
        user.password = password;
        user.imUsername = username;
        user.imPassword = password;
        user.login = YES;
    }
    
    if (![LIKEAppContext sharedInstance].user.isLogin) {
        [self performSegueWithIdentifier:@"accountSegue" sender:self];
    }
    else {
        
        BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
        
        if (!isAutoLogin) {
            //异步登陆账号
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:user.imUsername
                                                                password:user.imPassword
                                                              completion:
             ^(NSDictionary *loginInfo, EMError *error) {
                 if (loginInfo && !error) {
                     //获取群组列表
                     [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                     
                     //设置是否自动登录
                     [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                     
                     //将2.1.0版本旧版的coredata数据导入新的数据库
                     EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
                     if (!error) {
                         error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                     }
                     
                     //发送自动登陆状态通知
                     [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification object:@YES];
                     [self setupUnreadMessageCount];
                 }
                 else {
                     //completion([NSError errorWithDomain:@"instancemessage.login.error" code:error.errorCode userInfo:nil]);
                 }
             }
                                                                 onQueue:nil];
        }
        else {
            // 不作任何事儿
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
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
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.errorAutoLogin", @"chat", @"Automatic logon failure")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
                                     otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification object:@NO];
    }
    else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.beginAutoLogin", @"chat", @"Start automatic login...")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
                                     otherButtonTitles:nil, nil];
    }
    [alertView show];
}

// 结束自动登录回调
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.errorAutoLogin", @"chat", @"Automatic logon failure")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
                                     otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification object:@NO];
    }
    else{
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
        
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                               message:NSLocalizedStringFromTable(@"login.endAutoLogin", @"chat", @"End automatic login...")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
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
        str = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.beKicked", @"chat", @"you have been kicked out from the group of \'%@\'"), tmpStr];
    }
    if (str.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleConfirm
                                                                message:str
                                                             buttonType:UIAlertButtonOk];
        [alertView show];
    }
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error {
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.beRefusedToJoin", @"chat", @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                                        message:reason
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
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
    
    NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.agreedAndJoined", @"chat", @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", @"Prompt")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleConfirm
                                                                message:NSLocalizedStringFromTable(@"apns.failToBindDeviceToken", @"chat", @"Fail to bind device token")
                                                             buttonType:UIAlertButtonOk];
        [alertView show];
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
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.applyJoin", @"chat", @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.applyJoinWithName", @"chat", @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"group.sendApplyFail", @"chat", @"send application failure:%@\nreason：%@"), reason, error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"error", @"chat", @"Error")
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
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
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"friend.somebodyAddWithName", @"chat",  @"%@ add you as a friend"), username];
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

-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

// 统计未读消息数
- (void)setupUnreadMessageCount {
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
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
