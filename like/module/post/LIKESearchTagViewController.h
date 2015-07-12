//
//  LIKESearchTagViewController.h
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagView.h"

@protocol SearchDelegate <NSObject>

- (void)setTag:(NSString *)tagTitle type:(TagType)type;

@end

@protocol LIKETagsViewControllerProtocol;

// TODO: 这里的 protocol 的警告非常重要
@interface LIKESearchTagViewController : UIViewController <LIKETagsViewControllerProtocol>

@property (assign, nonatomic) id<SearchDelegate> delegate;

@property (readwrite, nonatomic, strong) UIImage *backgroundImage;

@property (readwrite, nonatomic, assign) TagType type;

@end
