//
//  LWAPIBaseManager.h
//  xiaomuren
//
//  Created by David Fu on 6/15/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, LWAPIManagerErrorType){
    LWAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    LWAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    LWAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    LWAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    LWAPIManagerErrorTypeTimeout,       //请求超时。RTApiProxy设置的是20秒超时，具体超时时间的设置请自己去看RTApiProxy的相关代码。
    LWAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM (NSUInteger, LWAPIManagerRequestType){
    LWAPIManagerRequestTypeGet,
    LWAPIManagerRequestTypePost,
    LWAPIManagerRequestTypeRestGet,
    LWAPIManagerRequestTypeRestPost
};



@class LWAPIBaseManager;

@protocol LWAPIManagerCallbackDelegate <NSObject>

- (void)didSuccessCallbackAPIManager:(LWAPIBaseManager *)manager;
- (void)didFailedCallbackAPIManager:(LWAPIBaseManager *)manager;

@end

@protocol LWAPIManagerParamSource <NSObject>

- (NSDictionary *)paramsForAPIManager:(LWAPIBaseManager *)manager;

@end

@protocol LWAPIManagerDataReformerProtocal <NSObject>

@required
- (id)manager:(LWAPIBaseManager *)manager reformData:(NSDictionary *)data;

@end

@protocol LWAPIManagerInterceptor <NSObject>

@optional
- (void)beforePerformSuccessAPIManager:(LWAPIBaseManager *)manager;
- (void)afterPerformSuccessAPIManager:(LWAPIBaseManager *)manager;

- (void)beforePerformFailAPIManager:(LWAPIBaseManager *)manager;
- (void)afterPerformFailAPIManager:(LWAPIBaseManager *)manager;

- (BOOL)manager:(LWAPIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(LWAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end


@protocol LWAPIManager <NSObject>

@required
- (NSString *)resourceName;
- (LWAPIManagerRequestType)requestType;

@optional
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

@end


@interface LWAPIBaseManager : NSObject

@property (readwrite, nonatomic, weak) id <LWAPIManagerParamSource> paramSource;
@property (readwrite, nonatomic, weak) id <LWAPIManagerInterceptor> interceptor;
@property (readwrite, nonatomic, weak) NSObject <LWAPIManager> *subclass;

@property (readonly, nonatomic, strong) NSError *error;
@property (readonly, nonatomic, assign) LWAPIManagerErrorType errorType;

@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)addDelegate:(id <LWAPIManagerCallbackDelegate>)delegate;
- (void)removeDelegate:(id <LWAPIManagerCallbackDelegate>)delegate;

- (id)fetchDataWithReformer:(id<LWAPIManagerDataReformerProtocal>)reformer;

- (NSInteger)loadData;

- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

// mehtod for overwrite by subclass
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

@end
