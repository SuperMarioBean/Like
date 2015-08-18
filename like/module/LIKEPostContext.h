//
//  LIKEPostContext.h
//  like
//
//  Created by David Fu on 8/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface LIKEPostContext : NSObject

@property (readonly, nonatomic, strong) NSMutableArray *timelineList;

@property (readonly, nonatomic, assign) NSInteger currentTimelinePage;

@property (readonly, nonatomic, strong) NSMutableArray *uploadList;

+ (instancetype)sharedInstance;

- (void)postWithPostID:(NSString *)postID completion:(void (^)(NSError *error))completion;

- (void)postWithKeyValuePairs:(NSDictionary *)keyValuePairs completion:(void (^)(NSError *error))completion;

- (void)deletePostWithPostID:(NSString *)postID completion:(void (^)(NSError *error))completion;

- (void)postListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion;

- (void)timelineWithPage:(NSInteger)page completion:(void (^)(NSError *error, NSArray *appendPostsArray))completion;

@end
