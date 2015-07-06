//
//  LIKEAPIProxy.m
//  xiaomuren
//
//  Created by David Fu on 6/15/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "LIKEAPIProxy.h"

NSInteger LIKEAPIProxyInvalidRequestID = -1;

@interface LIKEAPIProxy ()

@property (readwrite, nonatomic, strong) NSMutableDictionary *dispatchDictionary;
@property (readwrite, nonatomic, strong) NSNumber *recordedRequestID;

@property (readwrite, nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation LIKEAPIProxy

#pragma mark - life cycle

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LIKEAPIProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LIKEAPIProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

- (NSNumber *)p_lwCallApiWithRequest:(NSURLRequest *)request completion:(void (^)(NSError *error, id JSON, NSInteger requestID))completion {
    NSNumber *requestID = [self generateRequestID];
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        AFHTTPRequestOperation *storedOperation = self.dispatchDictionary[requestID];
        if (storedOperation == nil) {
            return;
        } else {
            [self.dispatchDictionary removeObjectForKey:requestID];
        }
        
        NSError *error;
        id JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"%@", error);
            completion? completion(error, nil, LIKEAPIProxyInvalidRequestID): nil;
            return;
        }
        
        completion? completion(nil, JSON, [requestID integerValue]): nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        AFHTTPRequestOperation *storedOperation = self.dispatchDictionary[requestID];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchDictionary removeObjectForKey:requestID];
        }
        
        completion? completion(error, nil, [requestID integerValue]): nil;
    }];
    
    self.dispatchDictionary[requestID] = httpRequestOperation;
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    return requestID;
}

- (NSNumber *)generateRequestID {
    if (_recordedRequestID == nil) {
        _recordedRequestID = @(1);
    } else {
        if ([_recordedRequestID integerValue] == NSIntegerMax) {
            _recordedRequestID = @(1);
        } else {
            _recordedRequestID = @([_recordedRequestID integerValue] + 1);
        }
    }
    return _recordedRequestID;
}


#pragma mark - accessor methods

- (NSMutableDictionary *)dispatchDictionary {
    if (!_dispatchDictionary) {
        _dispatchDictionary = [[NSMutableDictionary alloc] init];
    }
    return _dispatchDictionary;
}

- (AFHTTPRequestOperationManager *)operationManager {
    if (!_operationManager) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://xiaomu.ren"]];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _operationManager;
}

#pragma mark - api methods

- (NSInteger)callRestfulGETWithParams:(NSDictionary *)params
                         resourceName:(NSString *)resourceName
                           completion:(void (^)(NSError *error, id JSON, NSInteger requstID))completion {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:@"GET"
                                                                                    URLString:[[NSURL URLWithString:resourceName relativeToURL:self.operationManager.baseURL] absoluteString]
                                                                                   parameters:params
                                                                                        error:&serializationError];
    request.timeoutInterval = 5.0f;
    if (serializationError) {
        completion? completion(serializationError, nil, LIKEAPIProxyInvalidRequestID): nil;
        return -1;
    }
    
    NSNumber *requestId = [self p_lwCallApiWithRequest:request completion:^(NSError *error, id JSON, NSInteger requestID) {
        completion(error, JSON, requestID);
    }];
    return [requestId integerValue];
}

- (NSInteger)callRestfulPOSTWithParams:(NSDictionary *)params
                          resourceName:(NSString *)resourceName
                            completion:(void (^)(NSError *error, id JSON, NSInteger requstID))completion {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:@"POST"
                                                                                    URLString:[[NSURL URLWithString:resourceName relativeToURL:self.operationManager.baseURL] absoluteString]
                                                                                   parameters:params
                                                                                        error:&serializationError];
    request.timeoutInterval = 5.0f;

    if (serializationError) {
        completion? completion(serializationError, nil, LIKEAPIProxyInvalidRequestID): nil;
        return -1;
    }
    
    NSNumber *requestId = [self p_lwCallApiWithRequest:request completion:^(NSError *error, id JSON, NSInteger requestID) {
        completion(error, JSON, requestID);
    }];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSOperation *requestOperation = self.dispatchDictionary[requestID];
    [requestOperation cancel];
    [self.dispatchDictionary removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

@end
