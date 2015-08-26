//
//  LIKEHelper.h
//  like
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UINavigationBar+Helper.h"

#import "UICollectionView+Helper.h"

#import "UIColor+Hex.h"
#import "UIColor+section.h"

#import "UIFont+Font.h"

#import "NSArray+SafeAccess.h"

//#import "UIScrollView+BottomRefreshControl.h"

#import "UIImage+Color.h"
#import "UIImage+Resize.h"
#import "UIImage+Capture.h"
#import "UIResponder+Router.h"

#import "NSDateFormatter+Make.h"
#import "NSDate+Utilities.h"
#import "NSDate+TimeAgo.h"
#import "NSDate+Helper.h"

#import "NSString+Util.h"
#import "NSString+Emoji.h"
#import "NSString+Helper.h"

#import "UIViewcontroller+MBProgressHUD.h"

#import "NSError+StatusCode.h"

extern NSString *const LIKEContextCode;
extern NSString *const LIKEContextData;
extern NSString *const LIKEContextMessage;

@interface LIKEHelper : NSObject

+ (NSString *)randomStringWithMaxLength:(int)maxlength;

+ (CGSize)randomSize;

+ (NSString *)randomSizeString;

+ (NSString *)randomHexColorString;

+ (CGSize)formSize:(CGSize)size onWidth:(CGFloat)width;

NSString *getAppVersion();

+ (BOOL)verifyPhoneNumber:(NSString *)phoneNumber;

+ (BOOL)verifyPassword:(NSString *)password;

+ (BOOL)verifyUsername:(NSString *)username;

+ (BOOL)verifyDigistsCode:(NSString *)digistsCode;

+ (BOOL)veiryBirthday:(NSDate *)birthdayDate;

+ (id)dataWithResponceObject:(id)responceObject error:(NSError *__autoreleasing *)error;
    
@end
