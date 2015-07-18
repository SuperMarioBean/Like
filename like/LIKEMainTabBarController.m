//
//  LIKEMainTabBarController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMainTabBarController.h"

@interface LIKEMainTabBarController () <UITabBarControllerDelegate>

@end

@implementation LIKEMainTabBarController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.selectedIndex = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![LIKEAppContext sharedInstance].user.isLogin) {
        [self performSegueWithIdentifier:@"accountSegue" sender:self];
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
        [self performSegueWithIdentifier:@"postSegue" sender:self];
        return NO;
    }
    return YES;
}

#pragma mark - event response

- (IBAction)mainUnwind:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"publishUnwindSegue"]) {
        self.selectedIndex = 1;
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods


@end
