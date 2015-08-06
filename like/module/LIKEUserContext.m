//
//  LIKEUserContext.m
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEUserContext.h"

#import <SMS_SDK/SMS_SDK.h>

NSString const* LIKEUserPhoneNumber = @"username";
NSString const* LIKEUserUserID = @"id";
NSString const* LIKEUserIMUsername = @"imUsername";
NSString const* LIKEUserIMPassword = @"imPassword";

@implementation LIKEUserContext

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _forgetPassword = NO;
//        _login = NO;
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

+ (instancetype)sharedInstance {
    static LIKEUserContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LIKEUserContext alloc] init];
    });
    return sharedInstance;
}


- (void)loginWithPhoneNumber:(NSString *)phoneNumber
                    password:(NSString *)password
                  completion:(void (^)(NSError *))completion {
    [auth login:phoneNumber
       password:password
         sucess:^(id responseObject) {
             NSError *error;
             id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
             if (!error) {
                 _user = [[LIKEUser alloc] init];
                 self.user.username = data[LIKEUserPhoneNumber];
                 self.user.userID = data[LIKEUserUserID];
//                 self.user.imUsername = data[LIKEUserIMUsername];
//                 self.user.imPassword = data[LIKEUserIMPassword];
                 if ([self.user.username isEqualToString:@"18516103001"]) {
                     self.user.imUsername = @"test01";
                     self.user.imPassword = @"test01";
                 }
                 else if ([self.user.username isEqualToString:@"13601804009"]) {
                     self.user.imUsername = @"test02";
                     self.user.imPassword = @"test02";
                 }
                 
                 BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
                 
                 if (!isAutoLogin) {
                     //异步登陆账号
                     [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:self.user.imUsername
                                                                         password:self.user.imPassword
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
                              [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification
                                                                                  object:@YES];
                              
                              NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
                              NSInteger unreadCount = 0;
                              for (EMConversation *conversation in conversations) {
                                  unreadCount += conversation.unreadMessagesCount;
                              }
                              self.user.unreadCount = unreadCount;
                              completion(nil);
                          }
                          else {
                              NSError *retError = [NSError errorWithDomain:@"instancemessage.login.error"
                                                                      code:LIKEStatusCodeIMLoginError
                                                                  userInfo:nil];
                              completion(retError);
                          }
                      }
                                                                          onQueue:nil];
                 }
                 else {
                     // 自动登录
                     completion(nil);
                 }
             }
             else {
                 completion(error);
             }
         }
        failure:^(NSError *error) {
            NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                    code:LIKEStatusCodeNetworkError
                                                userInfo:nil];
            completion(retError);
        }];
}

- (void)logoutWithCompletion:(void (^)(NSError *))completion {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO
                                                                completion:^(NSDictionary *info, EMError *error) {
                                                                    if (!info && !error) {
                                                                        [[EaseMob sharedInstance].chatManager disableAutoLogin];
                                                                        // 临时处理, 这里其实是需要对每次 logout 的成功与否都要考虑在内
                                                                        [auth logout:nil failure:nil];
                                                                        [User logout:nil failure:nil];
                                                                        [post logout:nil failure:nil];
                                                                        [upload logout:nil failure:nil];
                                                                        [geo logout:nil failure:nil];
                                                                        _user = nil;
                                                                        completion(nil);
                                                                    }
                                                                    else {
                                                                        NSError *retError = [NSError errorWithDomain:@"instancemessage.logoff.error"
                                                                                                                code:LIKEStatusCodeIMLogoutError
                                                                                                            userInfo:nil];
                                                                        completion(retError);
                                                                    }
                                                                }
                                                                   onQueue:nil];
}

- (void)fetchVerificationCodeBySMSWithPhoneNumber:(NSString *)phoneNumber
                                             zone:(NSString *)zone
                                       completion:(void (^)(NSError *))completion {
    [SMS_SDK getVerificationCodeBySMSWithPhone:phoneNumber
                                          zone:zone
                                        result:^(SMS_SDKError *error) {
                                            if (!error) {
                                                completion(nil);
                                            }
                                            else {
                                                NSError *retError = [NSError errorWithDomain:@"verifySMS.getCode.error"
                                                                                        code:LIKEStatusCodeSMSFetchError
                                                                                    userInfo:nil];
                                                completion(retError);
                                                
                                            }
                                        }];
}

- (void)validateVerificationCodeBySMSWithPhoneNumber:(NSString *)phoneNumber
                                                zone:(NSString *)zone
                                                code:(NSString *)code
                                          completion:(void (^)(NSError *))completion {
    [auth smsVerify:phoneNumber
               zone:zone
        digistsCode:code
            success:^(id responseObject) {
                if ([responseObject[LIKEContextCode] integerValue] == 200) {
                    completion(nil);
                }
                else {
                    NSError *retError = [NSError errorWithDomain:@"verifySMS.getCode.error"
                                                            code:LIKEStatusCodeSMSValidateError
                                                        userInfo:nil];
                    completion(retError);
                }
            }
            failure:^(NSError *error) {
                NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                        code:LIKEStatusCodeNetworkError
                                                    userInfo:nil];
                completion(retError);
            }];
}

- (void)registWithPassword:(NSString *)password
                completion:(void (^)(NSError *))completion {
    [auth registUser:password
              sucess:^(id responseObject) {
                  NSError *error;
                  id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                  if (!error) {
                      completion(nil);
                  }
                  else {
                      completion(error);
                  }
              }
             failure:^(NSError *error) {
                 NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                         code:LIKEStatusCodeNetworkError
                                                     userInfo:nil];
                 completion(retError);
             }];
}

- (void)updateUserWithKeyValuePairs:(NSDictionary *)keyValuePairs
                         completion:(void (^)(NSError *))completion {
    [User updateUserInfo:keyValuePairs
                 success:^(id responseObject) {
                     NSError *error;
                     id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                     if (!error) {
                         /** set the data info to user **/
                         completion(nil);
                     }
                     else {
                         completion(error);
                     }
                 }
                 failure:^(NSError *error) {
                     NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                             code:LIKEStatusCodeNetworkError
                                                         userInfo:nil];
                     completion(retError);
                 }];
}

- (void)fetchUserWithUserID:(NSString *)userID completion:(void (^)(NSError *))completion {
    [User getUserInfo:userID
              success:^(id responseObject) {
                  NSError *error;
                  id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                  if (!error) {
                      /** set the data info to user **/
                      completion(nil);
                  }
                  else {
                      completion(error);
                  }
              }
              failure:^(NSError *error) {
                  NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                          code:LIKEStatusCodeNetworkError
                                                      userInfo:nil];
                  completion(retError);
              }];
}

- (void)followWithUserID:(NSString *)userID completion:(void (^)(NSError *))completion {
    [User follow:userID
         success:^(id responseObject) {
             completion(nil);
         }
         failure:^(NSError *error) {
             NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                     code:LIKEStatusCodeNetworkError
                                                 userInfo:nil];
             completion(retError);
         }];
}

- (void)unFollowWithUserID:(NSString *)userID completion:(void (^)(NSError *))completion {
    [User unfollow:userID
           success:^(id responseObject) {
             completion(nil);
           }
           failure:^(NSError *error) {
               NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                       code:LIKEStatusCodeNetworkError
                                                   userInfo:nil];
               completion(retError);
           }];
}

- (void)followerListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion {
    [User follower_list:page
                success:^(id responseObject) {
                    completion(nil);
                }
                failure:^(NSError *error) {
                    NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                            code:LIKEStatusCodeNetworkError
                                                        userInfo:nil];
                    completion(retError);
                }];
}

- (void)followingListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion {
    [User following_list:page
                 success:^(id responseObject) {
                     completion(nil);
                }
                 failure:^(NSError *error) {
                     NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                             code:LIKEStatusCodeNetworkError
                                                         userInfo:nil];
                     completion(retError);
                }];
}

- (void)mutualListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion {
    [User mutual_list:page
                success:^(id responseObject) {
                    completion(nil);
                }
                failure:^(NSError *error) {
                    NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                            code:LIKEStatusCodeNetworkError
                                                        userInfo:nil];
                    completion(retError);
                }];
}

@end
