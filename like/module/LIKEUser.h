//
//  LIKEUser.h
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LIKEUserPhotoURL;

@interface LIKEUser : NSObject

@property (readwrite, nonatomic, copy) NSString *userID;

@property (readwrite, nonatomic, copy) NSString *phoneNumber;

@property (readwrite, nonatomic, copy) NSString *password;

@property (readwrite, nonatomic, copy) NSString *username;

@property (readwrite, nonatomic, copy) NSString *imUsername;

@property (readwrite, nonatomic, copy) NSString *imPassword;

@property (readwrite, getter=isMale, nonatomic, assign) BOOL male;

@property (readwrite, nonatomic, strong) NSDate *birthday;

@property (readwrite, nonatomic, strong) NSURL *avatorURL;

@property (readwrite, nonatomic, strong) NSArray *followerList;

@property (readwrite, nonatomic, strong) NSArray *followingList;

@property (readwrite, nonatomic, strong) NSArray *mutualList;

@property (readwrite, nonatomic, assign) NSInteger unreadCount;

@property (readwrite, nonatomic, assign) NSArray* userLocation;

// debug
@property (readwrite, nonatomic, strong) NSMutableArray *testTrendsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testPhotosArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testWantsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testDinnersArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testQuestionsArray;

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           username:(NSString *)username
                           password:(NSString *)password
                               male:(BOOL)male
                           birthday:(NSDate *)birthday;

@end
