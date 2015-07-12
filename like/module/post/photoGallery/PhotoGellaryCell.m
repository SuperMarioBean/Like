//
//  PhotoGellaryCell.m
//  Like App
//
//  Created by Quan Changjun on 14/11/4.
//  Copyright (c) 2014年 S.K. All rights reserved.
//

#import "PhotoGellaryCell.h"

@implementation PhotoGellaryCell


-(void) animateSelection
{
    if([self viewWithTag:9]==nil)
    {
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        v.layer.borderColor = [[UIColor like_tintColor] CGColor];
        v.layer.borderWidth = 2.0f;
        v.backgroundColor = [UIColor blueColor];
        v.alpha = 0.1f;
        v.tag = 9;
        
        UIView * v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        v2.layer.borderColor = [[UIColor whiteColor] CGColor];
        v2.layer.borderWidth = 3.0f;
        v2.tag = 10;
        
        [self addSubview:v];
        [self addSubview:v2];
    }
}

-(void) animateDeselection
{
    UIView * v  = [self viewWithTag:9];
    [v removeFromSuperview];
    UIView * v2  = [self viewWithTag:10];
    [v2 removeFromSuperview];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self animateSelection];
    } else {
        [self animateDeselection];
    }
}
@end
