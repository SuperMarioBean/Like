//
//  LIKEPostContext.h
//  like
//
//  Created by David Fu on 8/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LIKEImageBaseURL;

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

@interface LIKEPostContext : NSObject

@property (readonly, nonatomic, strong) NSMutableArray *timelineList;

@property (readonly, nonatomic, assign) NSInteger currentTimelinePage;

@property (readonly, nonatomic, strong) NSMutableArray *uploadList;

+ (instancetype)sharedInstance;

- (void)postWithPostID:(NSString *)postID completion:(void (^)(NSError *error))completion;

- (NSURLSessionUploadTask*)postWithKeyValuePairs:(NSDictionary *)keyValuePairs image:(UIImage*)image completion:(void (^)(NSError *error))completion;

- (void)deletePostWithPostID:(NSString *)postID completion:(void (^)(NSError *error))completion;

- (void)postListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion;

- (void)timelineWithPage:(NSInteger)page completion:(void (^)(NSError *error, NSArray *appendPostsArray))completion;

@end
