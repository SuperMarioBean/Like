//
//  NSError+StatusCode.h
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LIKEStatusCode) {
    LIKEStatusCodeSuccess = 0,
    LIKEStatusCodeRegistUserExist = 2,
    LIKEStatusCodeLoginError,
    LIKEStatusCodeLogoutError,
    LIKEStatusCodeSMSFetchError,
    LIKEStatusCodeSMSValidateError,
    LIKEStatusCodeIMLoginError,
    LIKEStatusCodeIMLogoutError,
    LIKEStatusCodeNetworkError,
};

@interface NSError (StatusCode)

@end
