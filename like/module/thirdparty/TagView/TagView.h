//
//  TagView.h
//  Like
//
//  Created by Quan Changjun on 14-7-28.
//  Copyright (c) 2014年 Quan Changjun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TagDirection) {
    TagLeft = 0,
    TagRight
};

typedef NS_ENUM(NSInteger, TagType) {
    TagCustom = 0,
    TagLocation
};

@class TagView;

@protocol TagViewDelegate <NSObject>
@optional
- (void)didDeleteTagView:(TagView *)tagView;
- (void)TapOnTagView:(TagView*)sender;
@end

@interface TagView : UIView

@property (readwrite, nonatomic, assign) BOOL preventsPositionOutsideSuperview;

@property (readwrite, nonatomic, strong) NSString* tagTitle;
@property (readwrite, nonatomic, assign) TagDirection direction;
@property (readwrite, nonatomic, assign) TagType type;
@property (readwrite, nonatomic, strong) NSString* tagID;
@property (readwrite, nonatomic, assign) BOOL editable;
@property (readwrite, nonatomic, weak) id<TagViewDelegate> delegate;

- (id)initWithPoint:(CGPoint)point;
- (id)initWithPoint:(CGPoint)point isEditable:(BOOL)isEditable;
- (void)setLableText:(NSString *)text;
- (void)setLableText:(NSString *)text isInvert:(BOOL)isInvert;

@end

// example
// TagView* test = [[TagView alloc] initWithPoint:CGPointMake(100, 100)];
// [test setLableText:@"测试测试测试测试测试"];
// [test setLableText:@"测试测试测试测试测试" isInvert:YES];  //翻转
// [self.view addSubview:test];