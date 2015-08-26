//
//  LIKEPostContext.m
//  like
//
//  Created by David Fu on 8/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEPostContext.h"

NSString *const LIKETrendTimeline = @"userTimeline";
NSString *const LIKETrendContentImageURL = @"contentImageURL";
NSString *const LIKETrendContentImage = @"contentImage";
NSString *const LIKETrendContentText = @"contentText";
NSString *const LIkeTrendContentTagList = @"contentTagList";

NSString *const LIKETagTitle = @"tagTitle";
NSString *const LIKETagDirection = @"tagDirection";
NSString *const LIKETagType = @"tagType";
NSString *const LIKETagPosition = @"tagPostion";


NSString *const LIKEUploadThumbnailImage = @"uploadThumbnailImage";
NSString *const LIKEUploadProgress = @"uploadProgress";
NSString *const LIKEUploadStatus = @"uploadStatus";

NSString *const LIKEImageBaseURL = @"http://img.like.free-blade.com/";

@implementation LIKEPostContext

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentTimelinePage = 0;
        _timelineList = [NSMutableArray array];
        _uploadList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

+ (instancetype)sharedInstance {
    static LIKEPostContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LIKEPostContext alloc] init];
    });
    return sharedInstance;
}

- (void)postWithPostID:(NSString *)postID completion:(void (^)(NSError *))completion {
    [post getPost:postID
          success:^(id responseObject) {
              
          }
          failure:^(NSError *error) {
          }];
}

- (void)postListWithPage:(NSInteger)page completion:(void (^)(NSError *))completion {
    
}

- (void)timelineWithPage:(NSInteger)page completion:(void (^)(NSError *, NSArray *))completion {
    [post getTimeline:page
              success:^(id responseObject) {
                  NSError *error;
                  NSArray *data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                  if (!error) {
                      _currentTimelinePage = page;
                      
                      NSMutableArray *tempArray = [NSMutableArray array];
                      [tempArray addObjectsFromArray:data];
                      if (page == 1) {
                          [_timelineList removeAllObjects];
                      }
                      [_timelineList addObjectsFromArray:tempArray];
                      
                      completion(nil, tempArray);
                  }
                  else {
                      completion(error, nil);
                  }
              }
              failure:^(NSError *error) {
                  NSError *retError = [NSError errorWithDomain:@"afnetworking.error"
                                                          code:LIKEStatusCodeNetworkError
                                                      userInfo:nil];
                  completion(retError, nil);
              }];
}

- (NSURLSessionUploadTask*)postWithKeyValuePairs:(NSDictionary *)keyValuePairs image:(UIImage*)image completion:(void (^)(NSError *error))completion
{
    [upload uploadImage:image uploadProgress:^(CGFloat percent) {
        NSLog(@"upload : %d %%",(int)percent*100);
    } success:^(id responseObject) {
        NSError* error;
        NSDictionary* data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
        if (!error) {
            NSString *uri = [data objectForKey:@"uri"];
            NSMutableDictionary* postInfo = [NSMutableDictionary dictionaryWithDictionary:keyValuePairs];
            [postInfo setObject:uri forKey:LIKETrendContentImageURL];
            
            [post newPost:postInfo success:^(id responseObject) {
                if (completion) {
                    NSError *error;
                    [LIKEHelper dataWithResponceObject:responseObject error:&error];
                    if (error) {
                        completion([responseObject objectForKey:LIKEContextMessage]);
                    }else
                    {
                        completion(nil);
                    }
                }
            } failure:^(NSError *error) {
                if (completion) {
                    completion(error);
                }
            }];
        }else
        {
            NSLog(@"%@",error);
            if (completion) {
                completion(error);
            }
        }

    } failure:^(NSError *error) {
        NSLog(@"upload image fail.%@",error);
        if (completion) {
            completion(error);
        }
    }];
    
    return nil;
}


- (void)deletePostWithPostID:(NSString *)postID completion:(void (^)(NSError *error))completion
{
    [post delPost:postID success:^(id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}
@end
