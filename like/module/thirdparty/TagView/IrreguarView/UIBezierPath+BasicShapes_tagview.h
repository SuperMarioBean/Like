//
//  UIBezierPath+UIBezierPath_BasicShapes_tagview.h
//  Example
//
//  Created by Pierre Dulac on 26/02/13.
//  Copyright (c) 2013 Pierre Dulac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (BasicShapes_tagview)

+ (UIBezierPath *)tagShape:(CGRect)originalFrame;
+ (UIBezierPath *)tagShapeInvert:(CGRect)originalFrame;
@end
