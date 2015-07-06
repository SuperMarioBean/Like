//
//  LIKEAPIBaseManager.h
//  xiaomuren
//
//  Created by David Fu on 6/15/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, LIKEAPIManagerErrorType){
    LIKEAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    LIKEAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    LIKEAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    LIKEAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    LIKEAPIManagerErrorTypeTimeout,       //请求超时。RTApiProxy设置的是20秒超时，具体超时时间的设置请自己去看RTApiProxy的相关代码。
    LIKEAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM (NSUInteger, LIKEAPIManagerRequestType){
    LIKEAPIManagerRequestTypeGet,
    LIKEAPIManagerRequestTypePost,
    LIKEAPIManagerRequestTypeRestGet,
    LIKEAPIManagerRequestTypeRestPost
};



@class LIKEAPIBaseManager;

@protocol LIKEAPIManagerCallbackDelegate <NSObject>

- (void)didSuccessCallbackAPIManager:(LIKEAPIBaseManager *)manager;
- (void)didFailedCallbackAPIManager:(LIKEAPIBaseManager *)manager;

@end

@protocol LIKEAPIManagerParamSource <NSObject>

- (NSDictionary *)paramsForAPIManager:(LIKEAPIBaseManager *)manager;

@end

@protocol LIKEAPIManagerDataReformerProtocal <NSObject>

@required
- (id)manager:(LIKEAPIBaseManager *)manager reformData:(NSDictionary *)data;

@end

@protocol LIKEAPIManagerInterceptor <NSObject>

@optional
- (void)beforePerformSuccessAPIManager:(LIKEAPIBaseManager *)manager;
- (void)afterPerformSuccessAPIManager:(LIKEAPIBaseManager *)manager;

- (void)beforePerformFailAPIManager:(LIKEAPIBaseManager *)manager;
- (void)afterPerformFailAPIManager:(LIKEAPIBaseManager *)manager;

- (BOOL)manager:(LIKEAPIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(LIKEAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end


@protocol LIKEAPIManager <NSObject>

@required
- (NSString *)resourceName;
- (LIKEAPIManagerRequestType)requestType;

@optional
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

@end


@interface LIKEAPIBaseManager : NSObject

@property (readwrite, nonatomic, weak) id <LIKEAPIManagerParamSource> paramSource;
@property (readwrite, nonatomic, weak) id <LIKEAPIManagerInterceptor> interceptor;
@property (readwrite, nonatomic, weak) NSObject <LIKEAPIManager> *subclass;

@property (readonly, nonatomic, strong) NSError *error;
@property (readonly, nonatomic, assign) LIKEAPIManagerErrorType errorType;

@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)addDelegate:(id <LIKEAPIManagerCallbackDelegate>)delegate;
- (void)removeDelegate:(id <LIKEAPIManagerCallbackDelegate>)delegate;

- (id)fetchDataWithReformer:(id<LIKEAPIManagerDataReformerProtocal>)reformer;

- (NSInteger)loadData;

- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

// mehtod for overwrite by subclass
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

@end
