//
//  LWHelper.h
//  xiaomuren
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSString+Helper.h"
#import "UINavigationBar+Helper.h"
#import "UICollectionView+Helper.h"
#import "UIImage+Resize.h"
#import "UIColor+Hex.h"
#import "UIColor+Color.h"
#import "UIFont+Font.h"
#import "NSArray+SafeAccess.h"
#import "UIScrollView+BottomRefreshControl.h"
#import "UIImage+Color.h"

@interface LWHelper : NSObject

+ (NSString *)randomStringWithMaxLength:(int)maxlength;

+ (NSMutableArray *)testItems;

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
    
@end
