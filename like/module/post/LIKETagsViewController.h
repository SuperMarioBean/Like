//
//  LIKETagsViewController.h
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LIKETransferProcessedImageProtocol.h"
#import "TagView.h"
#import "LIKESearchTagViewController.h"

@protocol LIKETagsViewControllerProtocol <NSObject>

- (void)setType:(TagType)type;

- (void)setBackgroundImage:(UIImage *)backgoundImage;

@end

@interface LIKETagsViewController : UIViewController <LIKETransferProcessedImageProtocol,
                                                      SearchDelegate>

@property (readwrite, nonatomic, strong) UIImage *image;

@end
