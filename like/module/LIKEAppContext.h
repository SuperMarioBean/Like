//
//  LIKEAppContext.h
//  like
//
//  Created by David Fu on 6/16/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIKEUser.h"

extern NSString *const LIKETrendUserAvatarURL;
extern NSString *const LIKETrendUserNickname;
extern NSString *const LIKETrendUserGender;
extern NSString *const LIKETrendUserAge;
extern NSString *const LIKETrendUserLocation;
extern NSString *const LIKETrendTimeline;
extern NSString *const LIKETrendContentImageURL;
extern NSString *const LIKETrendContentImage;
extern NSString *const LIKETrendContentText;
extern NSString *const LIkeTrendContentTagList;

extern NSString *const LIKETagTitle;
extern NSString *const LIKETagDirection;
extern NSString *const LIKETagType;
extern NSString *const LIKETagPosition;

extern NSString *const LIKEUploadThumbnailImage;
extern NSString *const LIKEUploadProgress;
extern NSString *const LIKEUploadStatus;

@interface LIKEAppContext : NSObject

@property (readonly, nonatomic, strong) LIKEUser *user;

@property (readonly, getter=isReachable, nonatomic, assign) BOOL reachable;

@property (readwrite, nonatomic, assign) CGFloat width;

@property (readwrite, nonatomic, assign) CGFloat scaledWidth;

@property (readwrite, nonatomic, strong) NSMutableArray *localTagsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testTrendsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *testUploadTrendsArray;

+ (instancetype)sharedInstance;

@end
