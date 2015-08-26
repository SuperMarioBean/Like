//
//  LIKEUserContext.m
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEUserContext.h"

#import <SMS_SDK/SMS_SDK.h>

NSString *const LIKELoginSuccessNotification = @"login.success";
NSString *const LIKELoginFailureNotification = @"login.failure";
NSString *const LIKELogoutSuccessNotification = @"logout.success";
NSString *const LIKELogoutFailureNotification = @"logout.failure";

NSString *const LIKEUserCity = @"city";
NSString *const LIKEUserPhoneNumber = @"username";
NSString *const LIKEUserUserID = @"id";
NSString *const LIKEUserNickName = @"usernickname";
NSString *const LIKEUserGender = @"gender";
NSString *const LIKEUserBirthday = @"birthday";
NSString *const LIKEUserAvatorURL = @"avatorURL";

NSString *const LIKEUserGenderMale = @"M";
NSString *const LIKEUserGenderFemale = @"F";

NSString *const LIKEUserIMUsername = @"imusername";
NSString *const LIKEUserIMPassword = @"impassword";

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
                 self.user.imUsername = data[LIKEUserPhoneNumber];
                 self.user.imPassword = password;
                 
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
                              
                              NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
                              NSInteger unreadCount = 0;
                              for (EMConversation *conversation in conversations) {
                                  unreadCount += conversation.unreadMessagesCount;
                              }
                              self.user.unreadCount = unreadCount;
                              completion(nil);
                              //发送自动登陆状态通知
                              [[NSNotificationCenter defaultCenter] postNotificationName:LIKEIMLoginChangeNotification
                                                                                  object:@YES];
                              [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginSuccessNotification object:nil];
                          }
                          else {
                              NSError *retError = [NSError errorWithDomain:@"instancemessage.login.error"
                                                                      code:LIKEStatusCodeIMLoginError
                                                                  userInfo:nil];
                              completion(retError);
                              [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginFailureNotification object:nil];
                          }
                      }
                                                                          onQueue:nil];
                 }
                 else {
                     // 自动登录
                     completion(nil);
                     [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginSuccessNotification object:nil];
                 }
             }
             else {
                 completion(error);
                 [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginFailureNotification object:nil];
             }
         }
        failure:^(NSError *error) {
            NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                    code:LIKEStatusCodeNetworkError
                                                userInfo:nil];
            completion(retError);
            [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginFailureNotification object:nil];
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
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:LIKELogoutSuccessNotification object:nil];
                                                                    }
                                                                    else {
                                                                        NSError *retError = [NSError errorWithDomain:@"instancemessage.logoff.error"
                                                                                                                code:LIKEStatusCodeIMLogoutError
                                                                                                            userInfo:nil];
                                                                        completion(retError);
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:LIKELogoutFailureNotification object:nil];
                                                                    }
                                                                }
                                                                   onQueue:nil];
}

- (void)verificationCodeBySMSWithPhoneNumber:(NSString *)phoneNumber
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
                NSError *error;
                id __unused data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                
                if (!error) {
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

- (void)registWithPhoneNumber:(NSString *)phoneNumber
                     password:(NSString *)password
                   completion:(void (^)(NSError *))completion {
    [auth registUser:password
              sucess:^(id responseObject) {
                  NSError *error;
                  id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                  if (!error) {
                      [self loginWithPhoneNumber:phoneNumber
                                        password:password
                                      completion:^(NSError *error) {
                                          if (!error) {
                                              completion(nil);
                                          }
                                          else {
                                              completion(error);
                                          }
                                      }];
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

- (void)updateUserWithAvatorImage:(UIImage *)avatorImage keyValuePairs:(NSDictionary *)keyValuePairs completion:(void (^)(NSError *))completion {
    [upload uploadImage:avatorImage
         uploadProgress:nil
                success:^(id responseObject) {
                    NSError *error;
                    id data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                    if (!error) {
                        NSString *uri = data[@"uri"];
                        NSMutableDictionary *mutableKeyValuePairs = [NSMutableDictionary dictionaryWithDictionary:keyValuePairs];
                        mutableKeyValuePairs[LIKEUserAvatorURL] = uri;
                        /** set the data info to user **/
                        [self updateUserWithKeyValuePairs:mutableKeyValuePairs
                                               completion:^(NSError *error) {
                                                   if (!error) {
                                                       NSError *error;
                                                       NSDictionary *data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                                                       NSLog(@"%@", data);
                                                   }
                                                   else {
                                                       completion(error);
                                                   }
                        }];
                        
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

- (void)userWithUserID:(NSString *)userID completion:(void (^)(NSError *))completion {
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
