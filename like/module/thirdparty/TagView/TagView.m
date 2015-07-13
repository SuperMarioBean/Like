//
//  TagView.m
//  Like
//
//  Created by Quan Changjun on 14-7-28.
//  Copyright (c) 2014年 Quan Changjun. All rights reserved.
//

#import "TagView.h"
#import "IrregularView.h"
#import "UIBezierPath+BasicShapes_tagview.h"
#import "PulsingHaloLayer.h"

@interface TagView()<UIAlertViewDelegate>
@property (nonatomic, strong) UILabel * lable;
@property (nonatomic, strong) IrregularView* shape;
@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (nonatomic, strong) UIImageView *beaconView;

@property (nonatomic, strong) NSTimer* timer;
@end

#define BEACONSIZE 20.0f
#define VIEWHEIGHT 25.0f

@implementation TagView

#pragma mark - life cycle

//- (instancetype)initWithFrame:(CGRect)frame {
//    return [self initWithPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
//}

- (instancetype)initWithPoint:(CGPoint)point {
    return [self initWithPoint:point isEditable:YES];
}

- (instancetype)initWithPoint:(CGPoint)point isEditable:(BOOL)isEditable; {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(point.x, point.y - VIEWHEIGHT/2, 100, VIEWHEIGHT);

        _shape = [[IrregularView alloc] init];
        _shape.frame = CGRectZero;
        [self addSubview:_shape];
        _lable = [[UILabel alloc]init];
        _lable.frame = CGRectZero;
        [_shape addSubview:_lable];
        
        //add beacon
        CGFloat beaconSize = BEACONSIZE;
        _beaconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beacon"]];
        _beaconView.frame = CGRectMake(-beaconSize/2 , (self.frame.size.height-beaconSize)/2, beaconSize, beaconSize);
        
        self.halo = [PulsingHaloLayer layer];
        self.halo.position = _beaconView.center;
        self.halo.radius = 20;
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.5;
        anim.repeatCount = 100;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        [_beaconView.layer addAnimation:anim forKey:nil];
        [self addSubview:_beaconView];
        [self.layer insertSublayer:self.halo below:self.beaconView.layer];
        
        self.preventsPositionOutsideSuperview = NO;
        self.editable = isEditable;
        
        
        if (isEditable) {
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
            [self addGestureRecognizer:panGestureRecognizer];
        }
        
        self.lable.font = [UIFont systemFontOfSize:12.0];
        
    }
    return self;
}

#pragma mark - delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self.delegate didDeleteTagView:self];
        [self removeFromSuperview];
    };
}

#pragma mark - event response

- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        CGFloat x0 = view.center.x + translation.x;
        CGFloat y0 = view.center.y + translation.y;
        CGFloat x = view.center.x ;
        CGFloat y = view.center.y ;
        if(x0>self.frame.size.width/2&&x0<320-self.frame.size.width/2){
            x=x0;
        }
        if (y0>self.frame.size.height/2&&y0<320-self.frame.size.height/2) {
            y=y0;
        }
        [view setCenter:(CGPoint){x, y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

- (void)setType:(TagType)type {
    _type = type;
    
    switch (type) {
        case TagCustom: {
            _beaconView.image = [UIImage imageNamed:@"beacon"];
        }
            break;
        case TagLocation: {
            _beaconView.image = [UIImage imageNamed:@"lbeacon"];
        }
        default:
            break;
    }
}

- (void)setLableText:(NSString *)text {
    BOOL isInvert = (self.frame.origin.x + self.frame.size.width) > 320;
    [self setLableText:text isInvert:isInvert];
}

- (void)setLableText:(NSString *)text isInvert:(BOOL) isInvert {
    self.tagTitle = text;
    self.direction = isInvert? TagRight: TagLeft;
    CGFloat fontsize = 12.0;
    float textWidth = 0;
    CGSize size = CGSizeZero;
    size = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), fontsize)
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontsize]}
                              context:nil].size;
    textWidth = size.width;
    
    CGFloat xoffset  = BEACONSIZE * .3f;
    
    self.lable.text = text;
    self.lable.textAlignment = NSTextAlignmentCenter;
    
    _shape.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8f];
    
    if (isInvert) {
        CGFloat triWidth = self.frame.size.height*0.25f;
        CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, xoffset+triWidth+(textWidth+fontsize), self.frame.size.height);
        self.frame = frame;
        self.center = CGPointMake(self.center.x-self.frame.size.width, self.center.y);
        _beaconView.center = CGPointMake(_beaconView.center.x + self.frame.size.width, _beaconView.center.y);
        _halo.position = _beaconView.layer.position;
        
        _shape.frame = CGRectMake(0, 0, frame.size.width-xoffset, frame.size.height);
        _lable.frame = CGRectMake(0, 0, _shape.frame.size.width-triWidth, _shape.frame.size.height);
        [_shape setMaskWithPath:[UIBezierPath tagShapeInvert:_shape.frame]];
    }
    else{
        CGFloat triWidth = self.frame.size.height*0.35f;
        CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, xoffset+triWidth+(textWidth+fontsize*1.5), self.frame.size.height);
        self.frame = frame;
        _shape.frame = CGRectMake(2, 0, frame.size.width-xoffset, frame.size.height);
        _lable.frame = CGRectMake(triWidth, 0, _shape.frame.size.width-triWidth, _shape.frame.size.height);
        [_shape setMaskWithPath:[UIBezierPath tagShape:_shape.frame]];
    }
    
    [_shape onGesture:^(UIGestureRecognizer *tapGestrue) {
        
        if (self.editable) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除标签" message:@"确认删除此标签" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [alert show];
        }else
        {
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(TapOnTagView:)]) {
                    [self.delegate TapOnTagView:self];
                }
            }
        }
    }];
    
    
    _lable.text = text;
    _lable.font = [UIFont systemFontOfSize:fontsize];
    _lable.textColor = [UIColor whiteColor];
    _lable.backgroundColor = [UIColor clearColor];
    
    self.preventsPositionOutsideSuperview = YES;
}

#pragma mark - api methods


@end
