//
//  LIKEChatViewController.h
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LIKEChatViewController : UIViewController

@property (readwrite, nonatomic, assign) EMConversationType type;

@property (readwrite, nonatomic, strong) NSString *chatter;

@end
