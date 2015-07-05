//
//  LWAPIBaseManager.m
//  xiaomuren
//
//  Created by David Fu on 6/15/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "LWAPIBaseManager.h"
#import "LWAPIProxy.h"

@interface LWAPIBaseManager ()

@property (readwrite, nonatomic, strong) id fetchedRawData;

@property (readwrite, nonatomic, strong) GCDMulticastDelegate *multicastDelegate;

@property (readwrite, nonatomic, strong) NSError *error;
@property (readwrite, nonatomic, assign) LWAPIManagerErrorType errorType;
@property (readwrite, nonatomic, strong) NSMutableArray *requestIDArray;

@end

@implementation LWAPIBaseManager

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _multicastDelegate = [[GCDMulticastDelegate alloc] init];;
        _paramSource = nil;
        
        _fetchedRawData = nil;
        
        _error = nil;
        _errorType = LWAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(LWAPIManager)]) {
            self.subclass = (id <LWAPIManager>)self;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIDArray = nil;
}

#pragma mark - delegate methods

#pragma mark LWAPIManagerInterceptor

- (void)beforePerformSuccess {
    self.errorType = LWAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(beforePerformSuccessAPIManager:)]) {
        [self.interceptor beforePerformSuccessAPIManager:self];
    }
}

- (void)afterPerformSuccess {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(afterPerformFailAPIManager:)]) {
        [self.interceptor afterPerformFailAPIManager:self];
    }
}

- (void)beforePerformFail {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(beforePerformFailAPIManager:)]) {
        [self.interceptor beforePerformFailAPIManager:self];
    }
}

- (void)afterPerformFail {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(afterPerformFailAPIManager:)]) {
        [self.interceptor afterPerformFailAPIManager:self];
    }
}

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - event response

#pragma mark - private methods

- (void)p_lwRemoveRequestWithRequestID:(NSInteger)requestID {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestID in self.requestIDArray) {
        if ([storedRequestID integerValue] == requestID) {
            requestIDToRemove = storedRequestID;
        }
    }
    if (requestIDToRemove) {
        [self.requestIDArray removeObject:requestIDToRemove];
    }
}

- (void)p_lwSuccessedOnCallingAPIWithJSON:(id)JSON requestID:(NSInteger)requestID{
    if (JSON && [JSON count]) {
        self.fetchedRawData = JSON;
        [self p_lwRemoveRequestWithRequestID:requestID];
        id <LWAPIManagerCallbackDelegate> delegate;
        [self.interceptor beforePerformSuccessAPIManager:self];
        dispatch_queue_t dispatchQueue;
        GCDMulticastDelegateEnumerator *delegateEnumerator = [self.multicastDelegate delegateEnumerator];
        while ([delegateEnumerator getNextDelegate:&delegate delegateQueue:&dispatchQueue forSelector:@selector(didSuccessCallbackAPIManager:)]) {
            [delegate didSuccessCallbackAPIManager:self];
        }
        [self.interceptor afterPerformSuccessAPIManager:self];
    }
    else {
        [self p_lwFailedOnCallingAPIWithJSON:JSON error:[NSError errorWithDomain:@"content is empty" code:10000 userInfo:nil] errorType:LWAPIManagerErrorTypeNoContent requestID:requestID];
    }
}

- (void)p_lwFailedOnCallingAPIWithJSON:(id)JSON error:(NSError *)error errorType:(LWAPIManagerErrorType)type requestID:(NSInteger)requestID {
    self.error = error;
    self.errorType = type;
    [self p_lwRemoveRequestWithRequestID:requestID];
    
    [self.interceptor beforePerformFailAPIManager:self];
    id <LWAPIManagerCallbackDelegate> delegate;
    dispatch_queue_t dispatchQueue;
    GCDMulticastDelegateEnumerator *delegateEnumerator = [self.multicastDelegate delegateEnumerator];
    while ([delegateEnumerator getNextDelegate:&delegate delegateQueue:&dispatchQueue forSelector:@selector(didFailedCallbackAPIManager:)]) {
        [delegate didFailedCallbackAPIManager:self];
    }
    [self.interceptor afterPerformFailAPIManager:self];
}

#pragma mark - accessor methods

- (NSMutableArray *)requestIDArray {
    if (!_requestIDArray) {
        _requestIDArray = [[NSMutableArray alloc] init];
    }
    return _requestIDArray;
}

- (BOOL)isReachable {
    BOOL isReachability = [LWAppContext sharedInstance].isReachable;
    if (!isReachability) {
        self.errorType = LWAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

- (BOOL)isLoading {
    return [self.requestIDArray count] > 0;
}


#pragma mark - api methods

- (void)addDelegate:(id<LWAPIManagerCallbackDelegate>)delegate {
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<LWAPIManagerCallbackDelegate>)delegate {
    [self.multicastDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (NSInteger)loadData {
    NSDictionary *params = [self.paramSource paramsForAPIManager:self];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params {
    NSInteger requestID = 0;
    NSDictionary *apiParams = [self reformParams:params];
    
    if ([self shouldCallAPIWithParams:apiParams]) {
        if ([self isReachable]) {
            switch ([self.subclass requestType]) {
                case LWAPIManagerRequestTypeGet:
                    //AXCallAPI(GET, requestId);
                    break;
                case LWAPIManagerRequestTypePost:
                    //AXCallAPI(POST, requestId);
                    break;
                case LWAPIManagerRequestTypeRestPost: {
                    requestID = [[LWAPIProxy sharedInstance] callRestfulPOSTWithParams:apiParams resourceName:self.subclass.resourceName completion:^(NSError *error, id JSON, NSInteger requestID) {
                        if (!error) {
                            [self p_lwSuccessedOnCallingAPIWithJSON:JSON requestID:requestID];
                        }
                        else {
                            [self p_lwFailedOnCallingAPIWithJSON:JSON error:error errorType:LWAPIManagerErrorTypeDefault requestID:requestID];
                        }
                        [[self requestIDArray] addObject:@(requestID)];
                    }];
                }
                    break;
                case LWAPIManagerRequestTypeRestGet: {
                    requestID = [[LWAPIProxy sharedInstance] callRestfulGETWithParams:apiParams resourceName:self.subclass.resourceName completion:^(NSError *error, id JSON, NSInteger requestID) {
                        if (!error) {
                            [self p_lwSuccessedOnCallingAPIWithJSON:JSON requestID:requestID];
                        }
                        else {
                            [self p_lwFailedOnCallingAPIWithJSON:JSON error:error errorType:LWAPIManagerErrorTypeDefault requestID:requestID];
                        }
                        [[self requestIDArray] addObject:@(requestID)];
                    }];
                }
                    break;
                default:
                    break;
            }
            [self afterCallingAPIWithParams:params];
            return requestID;
        } else {
            [self p_lwFailedOnCallingAPIWithJSON:nil error:[NSError errorWithDomain:@"network not reachalbe" code:1000 userInfo:nil]
                                       errorType:LWAPIManagerErrorTypeNoNetWork
                                       requestID:requestID];
            return requestID;
        }
    }
    
    return requestID;
}

- (void)cancelAllRequests {
    [[LWAPIProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIDArray];
    [self.requestIDArray removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID {
    [self p_lwRemoveRequestWithRequestID:requestID];
    [[LWAPIProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (id)fetchDataWithReformer:(id<LWAPIManagerDataReformerProtocal>)reformer {
    id resultData = nil;
    if ([reformer conformsToProtocol:@protocol(LWAPIManagerDataReformerProtocal)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    }
    else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}

- (void)cleanData {
    IMP childIMP = [self.subclass methodForSelector:@selector(cleanData)];
    IMP selfIMP = [self methodForSelector:@selector(cleanData)];
    
    if (childIMP == selfIMP) {
        self.fetchedRawData = nil;
        self.error = nil;
        self.errorType = LWAPIManagerErrorTypeDefault;
    } else {
        if ([self.subclass respondsToSelector:@selector(cleanData)]) {
            [self.subclass cleanData];
        }
    }
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    IMP childIMP = [self.subclass methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        NSDictionary *result = nil;
        result = [self.subclass reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}


@end
