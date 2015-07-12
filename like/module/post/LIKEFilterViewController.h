//
//  LIKEFilterViewController.h
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LIKETransferProcessedImageProtocol.h"

@interface LIKEFilterViewController : UIViewController <LIKETransferProcessedImageProtocol>

@property (readwrite, nonatomic, strong) UIImage *image;

@end
