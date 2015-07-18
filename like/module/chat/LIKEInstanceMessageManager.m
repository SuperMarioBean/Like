//
//  LIKEInstanceMessageManager.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEInstanceMessageManager.h"

NSString *const LIKEIMLoginChangeNotification = @"loginChange";

@interface LIKEInstanceMessageManager ()


@end

@implementation LIKEInstanceMessageManager

#pragma mark - life cycle

#pragma mark - delegate methods

#pragma mark - IChatManagerDelegate

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
        
        
        // 旧数据转换 (如果您的sdk是由2.1.2版本升级过来的，需要家这句话)
        [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
        //获取数据库中的数据
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
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
    }
    
    [alertView show];
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
    [self.appliesArray addObject:dic];
    //    if (self.mainController) {
    //        [self.mainController setupUntreatedApplyCount];
    //    }s
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
        [self.appliesArray addObject:dic];
    }
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

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState {
    //_connectionState = connectionState;
    //[self.mainController networkChanged:connectionState];
}

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

- (NSArray *)conversationsArray {
    return [[EaseMob sharedInstance].chatManager conversations];
}

#pragma mark - api methods

- (void)loginWithCompletion:(void (^)(NSError *))completion {
    LIKEUser *user = [LIKEAppContext sharedInstance].user;
    [self loginWithUsername:user.imUsername password:user.imPassword completion:completion];
}

//登录
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))completion {
    //异步登陆账号
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username
                                                        password:password
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
             completion(nil);
         }
         else {
             completion([NSError errorWithDomain:@"instancemessage.login.error" code:error.errorCode userInfo:nil]);
         }
     }
                                                         onQueue:nil];
}

// 打印收到的apns信息
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"apns.content", @"chat", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"chat", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@end
