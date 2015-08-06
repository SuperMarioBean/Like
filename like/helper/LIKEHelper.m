//
//  LIKEHelper.m
//  like
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEHelper.h"

NSString *const LIKEContextCode = @"code";
NSString *const LIKEContextData = @"data";
NSString *const LIKEContextMessage = @"msg";

@implementation LIKEHelper

static NSString *const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *)randomStringWithMaxLength:(int)maxlength {
    u_int32_t length = arc4random_uniform(maxlength);
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (unsigned i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    
    return randomString;
}

+ (CGSize)randomSize {
    NSUInteger pickACat = arc4random_uniform(7) + 1;
    CGSize imageSize;
    switch (pickACat) {
        case 1:
            imageSize = CGSizeMake(200, 100);
            break;
        case 2:
        case 3:
        case 4:
            imageSize = CGSizeMake(200, 200);
            break;
        case 5:
        case 6:
            imageSize = CGSizeMake(200, 300);
            break;
        case 7:
            imageSize = CGSizeMake(200, 400);
            break;
        default:
            imageSize = CGSizeZero;
            break;
    }
    return imageSize;
}

+ (NSString *)randomSizeString {
    CGSize size = [self randomSize];
    return NSStringFromCGSize(size);
}

+ (NSString *)randomHexColorString {
    NSInteger baseInt = arc4random() % 16777216;
    NSString *hex = [NSString stringWithFormat:@"%06X", baseInt];
    return hex;
}

+ (CGSize)formSize:(CGSize)size onWidth:(CGFloat)width {
    if (size.height && size.width) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat height = floor(((size.height * width / size.width) * scale) / scale);
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

NSString *getAppVersion() {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (version.length == 0) {
        version = @"";
    }
    return version;
}

+ (BOOL)verifyPhoneNumber:(NSString *)phoneNumber {

    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    //    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    //    /**
    //     25         * 大陆地区固话及小灵通
    //     26         * 区号：010,020,021,022,023,024,025,027,028,029
    //     27         * 号码：七位或八位
    //     28         */
    //    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:phoneNumber] == YES)
        || ([regextestcm evaluateWithObject:phoneNumber] == YES)
        //        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:phoneNumber] == YES)) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)verifyPassword:(NSString *)password {
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

+ (BOOL)verifyUsername:(NSString *)username {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5]{1,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:username];
    return isMatch;
}

+ (BOOL)verifyDigistsCode:(NSString *)digistsCode {
    return digistsCode.length == 4;
}

+ (BOOL)veiryBirthday:(NSDate *)birthdayDate {
    return YES;
}

+ (id)dataWithResponceObject:(id)responceObject error:(NSError *__autoreleasing *)error {
    if ([responceObject[LIKEContextCode] integerValue] == LIKEStatusCodeSuccess) {
        *error = nil;
        return responceObject[LIKEContextData];
    }
    else {
        *error = [NSError errorWithDomain:responceObject[LIKEContextMessage]
                                     code:[responceObject[LIKEContextCode] integerValue]
                                 userInfo:nil];
        return nil;
    }
}

@end
