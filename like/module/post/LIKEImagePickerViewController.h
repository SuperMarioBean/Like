//
//  LIKEImagePickerViewController.h
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoGellaryViewController.h"

@interface LIKEImagePickerViewController : UIViewController <PhotoGellaryViewControllerProtocol>

- (void)setImageCropWithImage:(UIImage *)image;

@property (readwrite, getter=isFireOpen, nonatomic, assign) BOOL fireOpen;

@end
