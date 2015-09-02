//
//  LIKEUserContext.h
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIKEUser;

extern NSString *const LIKELoginSuccessNotification;
extern NSString *const LIKELoginFailureNotification;
extern NSString *const LIKELogoutSuccessNotification;
extern NSString *const LIKELogoutFailureNotification;

extern NSString *const LIKEUserCity;
extern NSString *const LIKEUserPhoneNumber;
extern NSString *const LIKEUserNickName;
extern NSString *const LIKEUserUserID;
extern NSString *const LIKEUserGender;
extern NSString *const LIKEUserBirthday;
extern NSString *const LIKEUserAvatorURL;
extern NSString *const LIKEUserVerify;
extern NSString *const LIKEUserAreaCode;
extern NSString *const LIKEUserDistance;
extern NSString *const LIKEUserHeight;

extern NSString *const LIKEUserGenderMale;
extern NSString *const LIKEUserGenderFemale;

extern NSString *const LIKEUserIMUsername;
extern NSString *const LIKEUserIMPassword;

@interface LIKEUserContext : NSObject

@property (readonly, nonatomic, strong) LIKEUser *user;

@property (readwrite, nonatomic, copy) NSString *tempPhoneNumber;

@property (readwrite, nonatomic, copy) NSString *tempPassword;

@property (readwrite, nonatomic, strong) UIImage *tempAvator;

@property (readwrite, getter=isForgetPassword, nonatomic, assign) BOOL forgetPassword;

//@property (readwrite, getter=isLogin, nonatomic, assign) BOOL login;

+ (instancetype)sharedInstance;

// 封装了 LIKE user 登录 和 IM 提供商的 IM 用户登录, USER 登陆成功后获得该用户的 IM 账号后再去登录(需要与权哥商量)
- (void)loginWithPhoneNumber:(NSString *)phoneNumber
                    password:(NSString *)password
                  completion:(void (^)(NSError *error))completion;

// 封装了所有二级域名的登出也包括了 IM 提供商的 IM 用户登出
- (void)logoutWithCompletion:(void (^)(NSError *error))completion;

// 根据电话号码获取验证码
- (void)verificationCodeBySMSWithPhoneNumber:(NSString *)phoneNumber
                                        zone:(NSString *)zone
                                  completion:(void (^)(NSError *error))completion;

// 验证SMS code
- (void)validateVerificationCodeBySMSWithPhoneNumber:(NSString *)phoneNumber
                                                zone:(NSString *)zone
                                                code:(NSString *)code
                                          completion:(void (^)(NSError *error))completion;

- (void)registWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password completion:(void (^)(NSError *error))completion;

- (void)updateUserWithAvatorImage:(UIImage *)avatorImage keyValuePairs:(NSDictionary *)keyValuePairs completion:(void (^)(NSError *error))completion;

- (void)updateUserWithKeyValuePairs:(NSDictionary *)keyValuePairs completion:(void (^)(NSError *error))completion;

- (void)userWithUserID:(NSString *)userID completion:(void (^)(NSError *error))completion;

- (void)followWithUserID:(NSString *)userID completion:(void (^)(NSError *error))completion;

- (void)unFollowWithUserID:(NSString *)userID completion:(void (^)(NSError *error))completion;

- (void)followerListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion;

- (void)followingListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion;

- (void)mutualListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion;

@end
