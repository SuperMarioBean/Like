//
//  LIKEUser.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEUser.h"

NSString *const LIKEUserPhotoURL = @"photoURL";

@implementation LIKEUser

#pragma mark - life cycle

- (instancetype)init {
    return [self initWithPhoneNumber:@"" username:@"" password:@"" male:YES birthday:nil];
}

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           username:(NSString *)username
                           password:(NSString *)password
                               male:(BOOL)male
                           birthday:(NSDate *)birthday {
    self = [super init];
    if (self) {
        _phoneNumber = phoneNumber;
        _username = username;
        _password = password;
        _male = male;
        _birthday = birthday;
        _imUsername = nil;
        _imPassword = nil;
        _avatorURL = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/h%3D200/sign=bb9571cabd12c8fcabf3f1cdcc0292b4/cefc1e178a82b901838ec0d9778da9773912ef3d.jpg"];
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

-(void) setUserLocation:(NSArray *)userLocation
{
    //lat|lon format
    NSString* upload_data = [NSString stringWithFormat:@"%@|%@",[userLocation objectAtIndex:0],[userLocation objectAtIndex:1]];
    [geo updateUserLocation:upload_data success:^(id responseObject) {
        _userLocation = userLocation;
    } failure:^(NSError *error) {
            NSLog(@"%@",error);
    }];
}

- (NSMutableArray *)testTrendsArray {
    return nil;
}

//- (NSMutableArray *)testTrendsArray {
//    if (!_testTrendsArray) {
//        _testTrendsArray = [NSMutableArray array];
//        NSDictionary *text1 = @{LIKEUserAvatorURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m9.png"],
//                                LIKEUserNickName: @"林星元",
//                                LIKEUserGender: @YES,
//                                LIKETrendTimeline: [NSDate date],
//                                LIKETrendUserLocation: @"上海",
//                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/ef8e65a2-198d-11e5-bb92-00163e004f70"],
//                                LIKETrendContentImage: [NSNull null],
//                                LIKETrendContentText: @"今天真是一个好天气,兄弟们,一起出来耍~",
//                                LIkeTrendContentTagList: @[@{LIKETagTitle: @"天气不错哦",
//                                                             LIKETagType: @(0),
//                                                             LIKETagDirection: @(1),
//                                                             LIKETagPosition: @"{100, 100}"
//                                                             }]
//                                };
//        
//        NSDictionary *text2 = @{LIKETrendUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m2.png"],
//                                LIKETrendUserNickname: @"张力泳",
//                                LIKETrendUserGender: @YES,
//                                LIKETrendUserAge: @(23),
//                                LIKETrendTimeline: [NSDate date],
//                                LIKETrendUserLocation: @"上海",
//                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/eeefa9c6-198d-11e5-bb92-00163e004f70"],
//                                LIKETrendContentImage: [NSNull null],
//                                LIKETrendContentText: @"今天遇到一个不错的姑娘,可惜错过了,希望下次不会有下次,大家也都要抓住机会,不要放过",
//                                LIkeTrendContentTagList: @[@{LIKETagTitle: @"我了个草不",
//                                                             LIKETagType: @(0),
//                                                             LIKETagDirection: @(1),
//                                                             LIKETagPosition: @"{150, 150}"
//                                                             }]
//                                };
//        
//        NSDictionary *text3 = @{LIKETrendUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f6.png"],
//                                LIKETrendUserNickname: @"宋慈玉",
//                                LIKETrendUserGender: @NO,
//                                LIKETrendUserAge: @(25),
//                                LIKETrendTimeline: [NSDate date],
//                                LIKETrendUserLocation: @"上海",
//                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/f06ec084-198d-11e5-bb92-00163e004f70"],
//                                LIKETrendContentImage: [NSNull null],
//                                LIKETrendContentText: @"有人一块看电影么,人家最近有空哦~",
//                                LIkeTrendContentTagList: @[@{LIKETagTitle: @"左边",
//                                                             LIKETagType: @(0),
//                                                             LIKETagDirection: @(0),
//                                                             LIKETagPosition: @"{120, 150}"
//                                                             },
//                                                           @{LIKETagTitle: @"右边",
//                                                             LIKETagType: @(0),
//                                                             LIKETagDirection: @(1),
//                                                             LIKETagPosition: @"{200, 150}"
//                                                             }
//                                                           ]
//                                };
//        
//        [_testTrendsArray addObject:text1];
//        [_testTrendsArray addObject:text2];
//        [_testTrendsArray addObject:text3];
//    }
//    return _testTrendsArray;
//}

- (NSMutableArray *)testPhotosArray {
    if (!_testPhotosArray) {
        _testPhotosArray = [NSMutableArray array];
        NSDictionary *text1 = @{LIKEUserPhotoURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/ef8e65a2-198d-11e5-bb92-00163e004f70"],
                                };
        NSDictionary *text2 = @{LIKEUserPhotoURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/f06ec084-198d-11e5-bb92-00163e004f70"]
                                };
        NSDictionary *text3 = @{LIKEUserPhotoURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/eeefa9c6-198d-11e5-bb92-00163e004f70"]
                                };
        [_testPhotosArray addObject:text1];
        [_testPhotosArray addObject:text2];
        [_testPhotosArray addObject:text3];
    }
    return _testPhotosArray;
}

- (NSMutableArray *)testWantsArray {
    if (!_testWantsArray) {
        _testWantsArray = [NSMutableArray array];
    }
    return _testWantsArray;
}

- (NSMutableArray *)testDinnersArray {
    if (!_testDinnersArray) {
        _testDinnersArray = [NSMutableArray array];
    }
    return _testDinnersArray;
}

- (NSMutableArray *)testQuestionsArray {
    if (!_testQuestionsArray) {
        _testQuestionsArray = [NSMutableArray array];
    }
    return _testQuestionsArray;
}

#pragma mark - api methods



@end
