//
//  NSError+StatusCode.h
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LIKEStatusCode) {
    LIKEStatusCodeLoginError,
    LIKEStatusCodeLogoutError,
    LIKEStatusCodeSMSFetchError,
    LIKEStatusCodeIMLoginError,
    LIKEStatusCodeIMLogoutError,
};

@interface NSError (StatusCode)

@end
