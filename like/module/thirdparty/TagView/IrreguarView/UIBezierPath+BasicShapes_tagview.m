//
//  UIBezierPath+UIBezierPath_BasicShapes_tagview.m
//  Example
//
//  Created by Pierre Dulac on 26/02/13.
//  Copyright (c) 2013 Pierre Dulac. All rights reserved.
//

#import "UIBezierPath+BasicShapes_tagview.h"
#define degreesToRadians(x) ((x) * M_PI / 180.0)

@implementation UIBezierPath (BasicShapes_tagview)

+ (CGRect)maximumSquareFrameThatFits:(CGRect)frame;
{
    CGFloat a = MIN(frame.size.width, frame.size.height);
    return CGRectMake(frame.size.width/2 - a/2, frame.size.height/2 - a/2, a, a);
}

+ (UIBezierPath *)tagShape:(CGRect)frame
{
    float radius = 5;
    float x1 = CGRectGetMinX(frame);
    float y1 = CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame);
    float x2 = CGRectGetMinX(frame) + 0.3 * CGRectGetHeight(frame);
    float y2 = CGRectGetMaxY(frame);
    float x3 = CGRectGetWidth(frame)-x1-1;
    float y3 = y2;
    float x4 = x3;
    float y4 = CGRectGetMinY(frame);
    float x5 = x2;
    float y5 = y4;
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(x1, y1)];
    [bezierPath addLineToPoint:CGPointMake(x2, y2)];
    CGPoint p1 = CGPointMake(x3-radius, y3);
    CGPoint p2 = CGPointMake(x3, y3-radius);
    [bezierPath addLineToPoint:p1];
    [bezierPath addArcWithCenter:CGPointMake(p1.x, p2.y) radius:radius startAngle:degreesToRadians(90) endAngle:degreesToRadians(0) clockwise:NO];
    
    p1 = CGPointMake(x4, y4+radius);
    p2 = CGPointMake(x4-radius, y4);
    [bezierPath addLineToPoint:p1];
    [bezierPath addArcWithCenter:CGPointMake(p2.x, p1.y) radius:radius startAngle:degreesToRadians(0) endAngle:degreesToRadians(-90) clockwise:NO];
    [bezierPath addLineToPoint:CGPointMake(x5, y5)];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    [bezierPath closePath];
    
    return bezierPath;
}

+ (UIBezierPath *)tagShapeInvert:(CGRect)frame
{
    float radius = 5.0f;
    float x1 = CGRectGetMinX(frame) + CGRectGetWidth(frame);
    float y1 = CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame);
    float x2 = x1 - 0.3 * CGRectGetHeight(frame);
    float y2 = CGRectGetMinY(frame) + CGRectGetHeight(frame);
    float x3 = CGRectGetMinX(frame);
    float y3 = y2;
    float x4 = x3;
    float y4 = CGRectGetMinY(frame);
    float x5 = x2;
    float y5 = y4;
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(x1, y1)];
    [bezierPath addLineToPoint:CGPointMake(x2, y2)];
    
    CGPoint p1 = CGPointMake(x3+radius, y3);
    CGPoint p2 = CGPointMake(x3, y3-radius);
    [bezierPath addLineToPoint:p1];
    [bezierPath addArcWithCenter:CGPointMake(p1.x, p2.y) radius:radius startAngle:degreesToRadians(90) endAngle:degreesToRadians(180) clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(x4, y4)];
    p1 = CGPointMake(x4, y4+radius);
    p2 = CGPointMake(x4+radius, y4);
    [bezierPath addLineToPoint:p1];
    [bezierPath addArcWithCenter:CGPointMake(p2.x, p1.y) radius:radius startAngle:degreesToRadians(180) endAngle:degreesToRadians(270) clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(x5, y5)];
    
    [bezierPath closePath];
    return bezierPath;

}

@end
