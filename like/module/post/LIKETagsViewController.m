//
//  LIKETagsViewController.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKETagsViewController.h"

#define contentY 20 + 44 + CGRectGetWidth([UIScreen mainScreen].bounds) + self.weiboShareButton.frame.size.height + 12

@interface LIKETagsViewController () <TagViewDelegate> {
    TagType _type;
}

@property (weak, nonatomic) IBOutlet UIButton *addCustomTagsButton;
@property (weak, nonatomic) IBOutlet UIButton *addLocationTagsButton;

@property (weak, nonatomic) IBOutlet UIButton *wechatFriendShareButton;
@property (weak, nonatomic) IBOutlet UIButton *wechatCirecleShareButton;
@property (weak, nonatomic) IBOutlet UIButton *weiboShareButton;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (readwrite, nonatomic, strong) UITextField *contentTextField;

@property (readwrite, nonatomic, strong) TagView *currentTagView;
@property (readwrite, nonatomic, strong) NSMutableArray *tags;

@property (readwrite, getter=isProcessAnimating, nonatomic, assign) BOOL processAnimating;
@property (readwrite, getter=isButtonAnimating, nonatomic, assign) BOOL buttonAnimating;


@end

@implementation LIKETagsViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addCustomTagsButton.alpha = .0f;
    self.addLocationTagsButton.alpha = .0f;
    
    self.processAnimating = NO;
    self.buttonAnimating = NO;

    self.imageView.image = self.image;
    
    self.tags = [NSMutableArray array];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.view addSubview:self.contentTextField];


    [self.view bringSubviewToFront:self.contentTextField];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keybaordWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark TagViewDelegate

- (void)didDeleteTagView:(TagView *)tagView {
    if ([tagView isEqual:self.currentTagView]) {
        self.currentTagView = nil;
    }
    
    [self.tags delete:tagView];
}

#pragma mark SearchDelegate

- (void)setTag:(NSString *)tagTitle type:(TagType)type {
    NSLog(@"add tag : %@", tagTitle);
    if ([tagTitle isEqual:@""]) {
        [self.currentTagView removeFromSuperview];
        self.currentTagView = nil;
    }
    else {
        [self.currentTagView setLableText:tagTitle];
        self.currentTagView.type = type;
        [self.tags addObject:self.currentTagView];
    }
}

#pragma mark - event response

- (IBAction)publishButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"publishUnwindSegue" sender:self];
}

- (void)keybaordWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    //    NSLog(@"%@",notification);
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    float duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self moveViewWithKeyboardHeight:keyboardRect.size.height withDuration:duration];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    float duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self moveViewWithKeyboardHeight:0 withDuration:duration];
}


- (IBAction)shareButtonClick:(UIButton *)sender {
    [sender setSelected:!sender.selected];
}

- (IBAction)tapGestureHandler:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.topView];
    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    
    if (self.contentTextField.isFirstResponder) {
        [self.contentTextField resignFirstResponder];
    }
    else
    {
        if (self.isProcessAnimating) {
            return;
        }
        
        if (self.addCustomTagsButton.layer.opacity == 0) {
            self.currentTagView = [[TagView alloc] initWithPoint:point];
            [self.topView addSubview:self.currentTagView];
            [self p_likeButtonShow];
        }else
        {
            [self p_likeButtonHide];
            [self.currentTagView removeFromSuperview];
            self.currentTagView = nil;
        }
    }
}

- (IBAction)addCustomTagsButtonClick:(id)sender {
    [self p_likeButtonHide];
    _type = TagCustom;
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
    
}
- (IBAction)addLocationTagsButtonClick:(id)sender {
    [self p_likeButtonHide];
    _type = TagLocation;
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"searchSegue"]) {
        LIKESearchTagViewController <LIKETagsViewControllerProtocol> *vc = [segue destinationViewController];
        UIImage* shareImage = [UIImage captureWithView:self.view];
        vc.backgroundImage = shareImage;
        vc.type = _type;
        vc.delegate = self;
    }
}

#pragma mark - private methods

- (void)p_likeAnimationShow:(UIView *)view {
    [view.layer removeAllAnimations];
    
    view.layer.opacity = 1.0f;
    float py0 = view.layer.position.y;
    //    view.layer.position = CGPointMake(view.layer.position.x, py0-30);
    
    //opacity animation
    CABasicAnimation *opAnim=[CABasicAnimation animationWithKeyPath:@"opacity"];
    opAnim.fromValue = @0;
    opAnim.toValue=@1;
    
    CABasicAnimation *moveAnim=[CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnim.fromValue = @(py0-30);
    moveAnim.toValue=@(py0);
    
    CAAnimationGroup *totalAnimation = [CAAnimationGroup animation];
    totalAnimation.duration = 0.3f;
    totalAnimation.animations = @[opAnim,moveAnim];
    totalAnimation.fillMode = kCAFillModeForwards;
    totalAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    totalAnimation.delegate = self;
    [view.layer addAnimation:totalAnimation forKey:@"buttonshowup"];
}

- (void)p_likeAnimationHide:(UIView *)view {
    [view.layer removeAllAnimations];
    view.layer.opacity = 0;
    float py0 = view.layer.position.y;
    view.layer.position = CGPointMake(view.layer.position.x, py0-30);
    
    //opacity animation
    CABasicAnimation *opAnim=[CABasicAnimation animationWithKeyPath:@"opacity"];
    opAnim.fromValue = @1;
    opAnim.toValue=@0;
    
    CABasicAnimation *moveAnim=[CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnim.fromValue = @(py0);
    moveAnim.toValue=@(py0-30);
    
    CAAnimationGroup *totalAnimation = [CAAnimationGroup animation];
    totalAnimation.duration = 0.3f;
    totalAnimation.animations = @[opAnim,moveAnim];
    totalAnimation.fillMode = kCAFillModeForwards;
    totalAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    totalAnimation.delegate = self;
    [view.layer addAnimation:totalAnimation forKey:@"buttonhidden"];
}

- (void)p_likeAnimationDidStart:(CAAnimation *)anim {
    self.processAnimating = YES;
}

- (void)p_likeAnimationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.processAnimating = NO;
}

- (void)p_likeButtonShow {
    self.buttonAnimating = YES;
    [self p_likeAnimationShow:self.addCustomTagsButton];
    [self p_likeAnimationShow:self.addLocationTagsButton];
    [self.topView bringSubviewToFront:self.addCustomTagsButton];
    [self.topView bringSubviewToFront:self.addLocationTagsButton];
}

- (void)p_likeButtonHide {
    self.buttonAnimating = YES;
    [self p_likeAnimationHide:self.addCustomTagsButton];
    [self p_likeAnimationHide:self.addLocationTagsButton];
}

- (void)moveViewWithKeyboardHeight:(CGFloat) height withDuration:(NSTimeInterval)duration {
    
    void(^animations)()=^(){
        if (height==0) {
            self.contentTextField.frame = CGRectMake(0, contentY, CGRectGetWidth([UIScreen mainScreen].bounds), 44);
        }
        else {
            self.contentTextField.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)- height - 44, CGRectGetWidth([UIScreen mainScreen].bounds), 44);
        }
    };
    
    if (height==0) {
        [UIView animateWithDuration:duration animations:animations completion:nil];
    }
    else {
        [UIView animateKeyframesWithDuration:duration delay:0.06 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:animations completion:nil];
    }
}

#pragma mark - accessor methods

#pragma mark - api methods

- (UITextField *)contentTextField {
    if (!_contentTextField) {
        _contentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _contentTextField.leftView.userInteractionEnabled = NO;
        _contentTextField.leftViewMode = UITextFieldViewModeAlways;
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, contentY, CGRectGetWidth(self.bottomView.frame), 44)];
        _contentTextField.font = [UIFont systemFontOfSize:14.0f];
        _contentTextField.backgroundColor = [UIColor grayColor];
        _contentTextField.textColor = [UIColor lightGrayColor];
        _contentTextField.placeholder = @"说点什么";
        _contentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        _contentTextField.leftView.userInteractionEnabled = NO;
        _contentTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _contentTextField;
}

@end
