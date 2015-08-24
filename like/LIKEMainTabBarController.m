//
//  LIKEMainTabBarController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMainTabBarController.h"
#import "LIKEInstanceMessageManager.h"

#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height)

@interface LIKEMainTabBarController () <UITabBarControllerDelegate,
                                        EMChatManagerDelegate,
                                        EMCallManagerDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)   NSArray *arrayImage;
@property (nonatomic, strong) UIScrollView *helpScrollView;

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
    
    // APP 第一次开启, 设置最初的欢迎页面
    // 始终为第一次打开应用
    [LIKEAppContext sharedInstance].hasWelcomeNewUser = NO;
    if (![LIKEAppContext sharedInstance].hasWelcomeNewUser) {
        [self startHelp];
    }
    
    
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
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"prompt", @"chat", nil)
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
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", @"chat", nil)
                                                     message:NSLocalizedStringFromTable(@"apns.failToBindDeviceToken", @"chat", @"Fail to bind device token")
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

#pragma mark - tutorials
- (void)startHelp
{
    _arrayImage = @[@"intro1", @"intro2", @"intro3"];
    self.helpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT];
    self.helpScrollView.pagingEnabled = YES;
    self.helpScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*_arrayImage.count, 0);
    [self.helpScrollView setShowsHorizontalScrollIndicator:NO];
    self.helpScrollView.delegate = self;
    [self.view addSubview:self.helpScrollView];
    CGSize size = self.helpScrollView.frame.size;
    
    for (int i=0; i< [_arrayImage count]; i++)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(size.width * i, 0, size.width, size.height)];
        [iv setImage:[UIImage imageNamed:[_arrayImage objectAtIndex:i]]];
        [self.helpScrollView addSubview:iv];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, [[UIScreen mainScreen] bounds].size.height)];
        [button setTag:i];
        [button addTarget:self action:@selector(onHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.helpScrollView addSubview:button];
    }
}

- (void)onHelpButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger buttonTag = button.tag + 1;
    if (buttonTag == _arrayImage.count)
    {
        [self hideHelpViewWithAnimation];
        return;
    }
    [self.helpScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*buttonTag, 0) animated:YES];
}

- (void)hideHelpViewWithAnimation
{
    if (_helpScrollView.hidden)
    {
        return;
    }
    [_helpScrollView setHidden:YES];
    // 创建CATransition对象
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    // 设定动画时间
    animation.duration = 0.5;
    // 设定动画快慢(开始与结束时较慢)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    
    // 动画开始
    [[_helpScrollView layer] addAnimation:animation forKey:@"animation"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width * 0.9))
    {
        [self hideHelpViewWithAnimation];
    }
    
    if (scrollView.contentOffset.x<0 ) {
        scrollView.contentOffset = CGPointZero;
    }
    
}
@end
