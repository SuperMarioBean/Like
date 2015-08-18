//
//  LikeMineViewController.m
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LikeMineViewController.h"
#import "TabBarTransitionController.h"
#import "TabBarControllerDelegate.h"
#import "ScrollTransition.h"

@interface LikeMineViewController () <UITabBarControllerDelegate>

@property (readwrite, nonatomic, strong) UITabBarController *tabBarController;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (readwrite, nonatomic, strong) TabBarTransitionController *tabBarTransitionController;

@property (readwrite, nonatomic, strong) TabBarControllerDelegate *tabBarControllerDelegate;

@property (readwrite, nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiver;

@end

@implementation LikeMineViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"tabBarEmbedSegue"]) {
        self.tabBarController = segue.destinationViewController;
        self.tabBarController.tabBar.hidden = YES;
        self.tabBarControllerDelegate = [[TabBarControllerDelegate alloc] initWithAnimator:[[ScrollTransition alloc] init]];
        self.tabBarController.delegate = self.tabBarControllerDelegate;
        self.tabBarTransitionController = [[TabBarTransitionController alloc] initWithTabBarController:self.tabBarController
                                                                              tabBarControllerDelegate:self.tabBarControllerDelegate];
    }
}

#pragma mark - delegate methods

#pragma mark UITabBarControllerDelegate

#pragma mark - event response
- (IBAction)logoutButtonClick:(id)sender {
    [self showHUD];
    [[LIKEUserContext sharedInstance] logoutWithCompletion:^(NSError *error) {
        if (!error) {
            [self hideHUDWithCompletionMessage:@"注销成功"];
            [[LIKEAppContext sharedInstance] setIsAutoLogin:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginSuccessNotification object:nil];
            });
        }
        else {
            [self hideHUDWithCompletionMessage:@"注销失败"];
            [[NSNotificationCenter defaultCenter] postNotificationName:LIKELoginFailureNotification object:nil];
        }
    }];
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods


@end
