//
//  LIKEMainNavigationController.m
//  like
//
//  Created by Quan Changjun on 15/8/26.
//  Copyright (c) 2015年 LIKE Technology. All rights reserved.
//

#import "LIKEMainNavigationController.h"

#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface LIKEMainNavigationController()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *helpScrollView;
@property(nonatomic,strong)   NSArray *arrayImage;
@end

@implementation LIKEMainNavigationController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // APP 第一次开启, 设置最初的欢迎页面
    // 始终为第一次打开应用
    [LIKEAppContext sharedInstance].hasWelcomeNewUser = NO;
    if (![LIKEAppContext sharedInstance].hasWelcomeNewUser) {
        [self startHelp];
    }

}

#pragma mark - tutorials
- (void)startHelp
{
    _arrayImage = @[@"intro1", @"intro2", @"intro3"];
    self.helpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.helpScrollView.pagingEnabled = YES;
    self.helpScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*_arrayImage.count, 0);
    [self.helpScrollView setShowsHorizontalScrollIndicator:NO];
    self.helpScrollView.delegate = self;
    [self.view addSubview:self.helpScrollView];
    CGSize size = self.helpScrollView.frame.size;
    
    for (int i=0; i< [_arrayImage count]; i++)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(size.width * i, 0, size.width, size.height)];
        [iv setImage:[UIImage imageNamed:[_arrayImage objectAtIndex:i]]];
        [self.helpScrollView addSubview:iv];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, [[UIScreen mainScreen] bounds].size.height)];
        [button setTag:i];
        [button addTarget:self action:@selector(onHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.helpScrollView addSubview:button];
    }
}

- (void)onHelpButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger buttonTag = button.tag + 1;
    if (buttonTag == _arrayImage.count)
    {
        [self hideHelpViewWithAnimation];
        return;
    }
    [self.helpScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*buttonTag, 0) animated:YES];
}

- (void)hideHelpViewWithAnimation
{
    if (_helpScrollView.hidden)
    {
        return;
    }
    [_helpScrollView setHidden:YES];
    // 创建CATransition对象
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    // 设定动画时间
    animation.duration = 0.5;
    // 设定动画快慢(开始与结束时较慢)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    
    // 动画开始
    [[_helpScrollView layer] addAnimation:animation forKey:@"animation"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width * 0.9))
    {
        [self hideHelpViewWithAnimation];
    }
    
    if (scrollView.contentOffset.x<0 ) {
        scrollView.contentOffset = CGPointZero;
    }
    
}

@end
