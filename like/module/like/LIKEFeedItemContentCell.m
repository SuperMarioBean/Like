//
//  LIKEFeedItemContentCell.m
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEFeedItemContentCell.h"

@interface LIKEFeedItemContentCell () {
    NSInteger _cursorIndex;
}

@property (readwrite, nonatomic, strong) NSMutableArray *tagsArray;

@end

@implementation LIKEFeedItemContentCell

- (void)awakeFromNib {
    self.tagsArray = [NSMutableArray arrayWithCapacity:2];
    _cursorIndex = 0;
}

- (void)beginTagsUpdate {
    _cursorIndex = 0;
}

- (void)updateTagWithPoint:(CGPoint)point
                     title:(NSString *)title
                      type:(TagType)type
                 direction:(TagDirection)direciton {
    TagView *tagView = [self.tagsArray objectWithIndex:_cursorIndex];
    if (tagView) {
        tagView.center = point;
    }
    else {
        tagView = [[TagView alloc] initWithPoint:point isEditable:NO];
        [self.tagsArray addObject:tagView];
    }
    [tagView setLableText:title];
    tagView.type = type;
    tagView.direction = direciton;
    if (!tagView.superview) {
        [self addSubview:tagView];
    }
    _cursorIndex ++;
}

- (void)endTagsUpdate {
    if (_cursorIndex < self.tagsArray.count) {
        for (NSUInteger index = _cursorIndex; index < self.tagsArray.count; index ++) {
            TagView *tagView = [self.tagsArray objectWithIndex:_cursorIndex];
            if (tagView) {
                [tagView removeFromSuperview];
                [self.tagsArray removeObject:tagView];
            }
        }
    }
}

@end
