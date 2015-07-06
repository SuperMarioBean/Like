//
//  LIKEMainTabBarController.m
//  xiaomuren
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "LIKEMainTabBarController.h"

@interface LIKEMainTabBarController () <UITabBarControllerDelegate>

@end

@implementation LIKEMainTabBarController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor shironeriColor]]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!__user.isLogin) {
        [self performSegueWithIdentifier:@"account" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - delegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2) {
        [self performSegueWithIdentifier:@"custom&valuate" sender:self];
        return NO;
    }
    return YES;
}

#pragma mark - event response

- (IBAction)mainUnwind:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"main unwind");
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods


@end
